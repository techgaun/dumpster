defmodule Brighterx.Mixfile do
  use Mix.Project

  def project do
    [app: :brighterx,
     version: "0.0.4",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     description: "A simple brighterlink api implementation",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test, "coveralls.semaphore": :test],
     docs: [logo: "logo/brighterlink_logo.png",
            extras: ["README.md"]]
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.0 or ~> 3.0"},
      {:excoveralls, "~> 0.5.4", only: :test},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:dogma, "~> 0.1", only: [:dev, :test]},
      {:mock, "~> 0.1.1", only: :test}
    ]
  end

  defp package do
    [
      maintainers: [
        "Samar Acharya",
        "Bruce Wang"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Brightergy/brighterx"}
    ]
  end

end
