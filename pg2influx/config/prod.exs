use Mix.Config

config :moebius, connection: [
  url: System.get_env("DATABASE_URL"),
  pool_mod: DBConnection.Poolboy
]
