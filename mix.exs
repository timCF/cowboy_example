defmodule CowboyEx.Mixfile do
  use Mix.Project

  def project do
    [app: :cowboy_ex,
     version: "0.0.1",
     #elixir: "~> 0.14.1",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [
                    :exdk,
                    :cowboy,
                    :exactor,
                    :jazz,
                    :bullet,
                    #:amnesia
                    :exlager
                    ],
     mod: {CowboyEx, []}]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      #{:amnesia, github: "meh/amnesia"},
      {:exlager, github: "khia/exlager"},
      {:bullet, github: "extend/bullet"},
      {:jazz, github: "meh/jazz"},
      {:exdk, github: "timCF/exdk"},
      {:cowboy, github: "extend/cowboy", tag: "0.9.0"},
      {:exrm, github: "bitwalker/exrm"},
      {:exactor, github: "sasa1977/exactor"}
    ]
  end
end
