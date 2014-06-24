defmodule CowboyEx.Mixfile do
  use Mix.Project

  def project do
    [app: :cowboy_ex,
     version: "0.0.1",
     elixir: "~> 0.14.1",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [
                    :cowboy,
                    :exactor
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
      {:cowboy, github: "extend/cowboy"},
      {:exrm, github: "bitwalker/exrm"},
      {:exactor, github: "sasa1977/exactor"}
    ]
  end
end
