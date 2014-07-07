defmodule CowboyEx do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [ worker(CowboyEx.OnlineUserkeeper, [])
      # Define workers and child supervisors to be supervised
      # worker(CowboyEx.Worker, [arg1, arg2, arg3])
    ]

    CowboyEx.WebRoutes.start

    :pg2.create("users")

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CowboyEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end


defmodule CowboyEx.WebRoutes do



  def start do

  dispatch = :cowboy_router.compile([
                      {:_, [

                          {"/bullet", :bullet_handler, [{:handler, CowboyEx.WebHandler}]},
                          {"/", :cowboy_static, {:priv_file, :cowboy_ex, "static/index.html"}},
                          {"/[...]", :cowboy_static, {:priv_dir, :cowboy_ex, "static",
                          [{:mimetypes, :cow_mimetypes, :all}]}},

                          {:_, CowboyEx.NotFound, []}
                        ]}
                  ])

    :cowboy.start_http(:http_listener, 5000, [port: 8080], [env: [
        dispatch: dispatch
      ]
    ])
  end
end
defmodule CowboyEx.WebHandler do

  require Lager

  defmodule ChatProtocol do
    defstruct type: nil, content: nil
  end

  def init(_Transport, req, _Opts, _Active) do
      
      :pg2.join("users", self)

      IO.puts "\nINIT"
      IO.puts "\nTRANSPORT:"
      IO.inspect _Transport
      IO.puts "\nREQUEST:"
      IO.inspect req
      IO.puts "\nOPTIONS:"
      IO.inspect _Opts
      IO.puts "\nACTIVE:"
      IO.inspect _Active
      {:ok, req, :undefined_state}
  end

  def stream(data, req, state) do
      IO.puts "\nSTREAM"
      IO.puts "\nDATA:"
      IO.inspect data
      IO.puts "\nREQUEST:"
      IO.inspect req
      IO.puts "\nSTATE:"
      IO.inspect state

      ans = case mess = (Jazz.decode(data, keys: :atoms)) do
              {:ok, map} -> case map do
                              %{type: type, content: content} -> handle_message_from_client(%ChatProtocol{type: type, content: content})
                              _ ->  Lager.emergency "Error on protocol from client. Content: #{inspect mess}"
                                    Jazz.encode!(%ChatProtocol{type: "error", content: "Error on protocol from client. Content: #{inspect mess}"})
                            end
              _ ->  Lager.emergency "Error on parsing message from client. Content: #{inspect mess}"
                    Jazz.encode!(%ChatProtocol{type: "error", content: "parsing JSON error on server\nincoming messge:\n#{inspect data}"})
            end

      {:reply, ans, req, state}
  end

  def info(_Info, req, state) do
      IO.puts "\nINFO"
      IO.puts "\nINFO:"
      IO.inspect _Info
      IO.puts "\nREQUEST:"
      IO.inspect req
      IO.puts "\nSTATE:"
      IO.inspect state
      {:ok, req, state}
  end

  def terminate(req, state) do

    :pg2.leave "users", self

      IO.puts "\nTERMINATE" 
      IO.puts "\nREQUEST:"
      IO.inspect req
      IO.puts "\nSTATE:"
      IO.inspect state
      :ok
  end

  defp handle_message_from_client( %ChatProtocol{type: type, content: content} ) do
    case type do
      "ping" -> IO.puts content
                case content do
                  "anon" -> Jazz.encode!(%ChatProtocol{type: "update_username", content: inspect(self)})
                  <<"#PID<", _rest::binary>> -> Jazz.encode!(%ChatProtocol{type: "update_username", content: inspect(self)})
                  bin when is_binary(bin) -> try_update_username(bin)
                end
    end
  end

  defp try_update_username new_username do
    case CowboyEx.OnlineUserkeeper.user_exist?(new_username) do
      true -> Jazz.encode!(%ChatProtocol{type: "error", content: "User #{new_username} is already exist!"})
      false ->  CowboyEx.OnlineUserkeeper.add_user(new_username)
                Jazz.encode!(%ChatProtocol{type: "update_username", content: new_username})
    end
  end

end