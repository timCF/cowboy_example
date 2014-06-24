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
                          {"/", CowboyEx.WebHandler, []},
                          {"/[...]", :cowboy_static, {:priv_dir, :cowboy_ex, "",
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
    
    {:ok, data} = File.read :erlang.list_to_binary(:code.priv_dir(:cowboy_ex))<>"/index.html"

    {:ok, req} = :cowboy_req.reply 200, [], data, req
    {:ok, req, state}
  end

  def terminate(_request, _state, _) do
    :ok
  end
end

defmodule CowboyEx.NotFound do

   @behaviour :cowboy_http_handler

  def init({_any, :http}, req, []) do
    {:ok, req, :undefined}
  end

  def handle(req, state) do
    #{:ok, data} = File.read "./priv/index.html"
    
    data = 
    """
    <!doctype html>
    <html lang="en">
        <head>
            <title>Example Application</title>
            <meta charset="utf-8">
            <META HTTP-EQUIV="refresh" CONTENT="1">
            <style type="text/css">
                @import url(http://fonts.googleapis.com/css?family=Roboto);
                
                body {
                    background-color: #fff;
                    color: #484848;
                    font: normal 15px/1.8 Roboto, Verdana, sans-serif;
                }

                p {
                    margin-bottom: 1.8em;
                    width: 30em;
                }
            </style>
        </head>
        <body>
            <p>NOT FOUND</p>
        </body>
    </html>
    """

    {:ok, req} = :cowboy_req.reply 404, [], data, req
    {:ok, req, state}
  end

  def terminate(_request, _state, _) do
    :ok
  end
end