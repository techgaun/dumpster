use Mix.Config

config :moebius, connection: [
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "brighterlink_io_test",
  pool_mod: DBConnection.Poolboy
]

config :pg2influx, BrighterlinkIo.InfluxConnection,
  host: "localhost",
  port: 8086,
  database: "brighterlink_io_test"
