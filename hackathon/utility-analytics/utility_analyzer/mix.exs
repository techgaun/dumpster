defmodule UtilityAnalyzer.Mixfile do
  use Mix.Project

  def project do
    [app: :utility_analyzer,
    description: "An elixir prototype to process and parse PDFs for Utility Bills",
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:exfswatch, :logger, :postgrex, :ecto],
     mod: {UtilityAnalyzer, []}]
  end

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
      {:sh, "~> 1.1"},
      {:exfswatch, "~> 0.1.1"},
      {:postgrex, "~> 0.11.1"},
      {:ecto, "~> 1.1.8"},
      {:poison, "~> 2.0"}
    ]
  end
end
