use Mix.Config

config :utility_analyzer,
  disable_file_move: false

config :utility_analyzer, UtilityAnalyzer.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_size: 20
