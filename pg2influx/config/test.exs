use Mix.Config

config :moebius, connection: [
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "brighterlink_io_test",
  pool_mod: DBConnection.Poolboy
]
