defmodule HubGateway.Mixfile do
  use Mix.Project

  def project do
    [app: :hub_gateway,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {HubGateway.Application, []},
     extra_applications: [:logger, :runtime_tools, :ssl, :sentry]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:phoenix_gen_socket_client, "~> 1.0"},
     {:websocket_client, github: "sanmiguel/websocket_client", tag: "1.1.0"},
     {:msgpax, "~> 1.1"},
     {:gproc, "~> 0.6.1"},
     {:distillery, "~> 1.4"},
     {:ex_erlstats, "~> 0.1.5"},
     {:mock, "~> 0.2.1", only: :test},
     {:excoveralls, "~> 0.6", only: :test},
     {:auth0_ex, "~> 0.1", only: [:dev, :test]},
     {:dogma, "~> 0.1", only: [:dev, :test]},
     {:sobelow, "~> 0.3"},
     {:sentry, "~> 5.0.1"}
    ]
  end

  defp aliases do
    [
      "casa.seccheck": "sobelow --exit medium",
      "recompile": ~w(clean compile)
    ]
  end
end
