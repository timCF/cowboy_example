defmodule CowboyEx do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [  worker(CowboyEx.OnlineUserkeeper, []),
                  worker(CowboyEx.Messanger, [])
      # Define workers and child supervisors to be supervised
      # worker(CowboyEx.Worker, [arg1, arg2, arg3])
    ]

    prepare_script()

    CowboyEx.WebRoutes.start

    :pg2.create("users")

    #:application.stop :lager
    :application.start :sasl

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CowboyEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp prepare_script do
    ip = System.cmd("curl ifconfig.me/ip")
          |> String.split("\n")
            |> Enum.filter(&(&1 != ""))
              |> List.last
    res = File.read!( (:erlang.list_to_binary(:code.priv_dir(:cowboy_ex)))<>"/static/js/myscript_template.js" )
            |> String.replace("SERVER_IP_ADDRESS", ip)
    File.write!( (:erlang.list_to_binary(:code.priv_dir(:cowboy_ex)))<>"/static/js/myscript.js", res )
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
                              _ ->  #Lager.emergency "Error on protocol from client. Content: #{inspect mess}"
                                    Jazz.encode!(%ChatProtocol{type: "error", content: "Error on protocol from client. Content: #{inspect mess}"})
                            end
              _ ->  #Lager.emergency "Error on parsing message from client. Content: #{inspect mess}"
                    Jazz.encode!(%ChatProtocol{type: "error", content: "parsing JSON error on server\nincoming messge:\n#{inspect data}"})
            end

      {:reply, ans, req, state}
  end

  def info({:user_entered, username}, req, state) do
      IO.puts "\nINFO"
      IO.puts "\nINFO:"
      #IO.inspect _Info
      IO.puts "\nREQUEST:"
      IO.inspect req
      IO.puts "\nSTATE:"
      IO.inspect state

      File.write "./tmp", "hi there!"

      ans = Jazz.encode!(%ChatProtocol{type: "update_userlist", content: CowboyEx.OnlineUserkeeper.get_userlist_html()})

      {:reply, ans, req, state}
  end
  def info({:user_exited, username}, req, state) do
      IO.puts "\nINFO"
      IO.puts "\nINFO:"
      #IO.inspect _Info
      IO.puts "\nREQUEST:"
      IO.inspect req
      IO.puts "\nSTATE:"
      IO.inspect state

      ans = Jazz.encode!(%ChatProtocol{type: "update_userlist", content: CowboyEx.OnlineUserkeeper.get_userlist_html()})

      {:reply, ans, req, state}
  end
  def info({:add_new_message, mess}, req, state) do

      File.write "./tmp", "hi there!"

      File.write "./tmp", Jazz.encode!(%ChatProtocol{type: "add_message", content: mess})

      ans = Jazz.encode!(%ChatProtocol{type: "add_message", content: mess})

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
      "ping" -> case content do
                  "anon" -> CowboyEx.OnlineUserkeeper.add_username(prepare_anon)
                            Jazz.encode!(%ChatProtocol{type: "update_username", content: prepare_anon})
                  bin when (is_binary(bin) or is_number(bin)) ->  ping_username(to_string(bin))
                end
      "update_username" -> case content do
                            "anon" ->   CowboyEx.OnlineUserkeeper.add_username(prepare_anon)
                                        Jazz.encode!(%ChatProtocol{type: "update_username", content: prepare_anon})
                            <<"#PID", _rest::binary>> ->  CowboyEx.OnlineUserkeeper.add_username(prepare_anon)
                                                          Jazz.encode!(%ChatProtocol{type: "update_username", content: prepare_anon})
                            bin when (is_binary(bin) or is_number(bin)) ->  try_update_username(to_string(bin))
                          end
      "text_mesage" ->  %{message: message, autor: autor} = content
                        CowboyEx.Messanger.process_new_message(message, autor)
                        Jazz.encode!(%ChatProtocol{type: "done", content: "null"})
      "get_history" ->  Jazz.encode!(%ChatProtocol{type: "set_history", content: CowboyEx.Messanger.get_history_html})

    end
  end

  defp ping_username username do
    CowboyEx.OnlineUserkeeper.ping_username(username)
    Jazz.encode!(%ChatProtocol{type: "update_username", content: username})
  end

  defp try_update_username new_username do
    case CowboyEx.OnlineUserkeeper.user_exist?(new_username) do
      true ->   CowboyEx.OnlineUserkeeper.add_username(prepare_anon)
                Jazz.encode!(%ChatProtocol{type: "update_username", content: prepare_anon})
      false ->  CowboyEx.OnlineUserkeeper.add_username(new_username)
                Jazz.encode!(%ChatProtocol{type: "update_username", content: new_username})
    end
  end

  defp prepare_anon do
    String.replace(inspect(self), "<", " ")
      |> String.replace(">", " ")
  end

end