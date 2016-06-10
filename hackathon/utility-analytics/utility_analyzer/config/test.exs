use Mix.Config

config :utility_analyzer,
  disable_file_move: false

config :utility_analyzer, UtilityAnalyzer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "postgres",
  database: "utility_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
