defmodule CowboyEx do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(CowboyEx.Worker, [arg1, arg2, arg3])
    ]

    CowboyEx.WebRoutes.start

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
                          #static("css"),
                          #static("js"),
                          #static("img"),

                          #{("/index.html"), CowboyEx.WebHandler, []},
                          {"/query/[...]", CowboyEx.WebHandler, []},
                          {"/", :cowboy_static, {:priv_file, :cowboy_ex, "content/index.html"}},
                          {"/[...]", :cowboy_static, {:priv_dir, :cowboy_ex, "content",
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

   @behaviour :cowboy_http_handler

  def init({_any, :http}, req, []) do
    {:ok, req, :undefined}
  end

  def handle(req, state) do
    
    #{:ok, data} = File.read :erlang.list_to_binary(:code.priv_dir(:cowboy_ex))<>"/index.html"
    {text, req} = :cowboy_req.qs_val("text", req)
    IO.puts "Text == #{inspect text}"

    {:ok, req} = :cowboy_req.reply 200, [], inspect(req), req
    {:ok, req, state}
  end

  def terminate(_request, _state, _) do
    :ok
  end
end