use Mix.Config

config :utility_analyzer,
  disable_file_move: true

config :utility_analyzer, UtilityAnalyzer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "utility_dev",
  hostname: "localhost",
  pool_size: 10
