use Mix.Config

config :moebius, connection: [
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_mod: DBConnection.Poolboy
]

config :pg2influx, BrighterlinkIo.InfluxConnection,
  host: "localhost",
  port: 8086,
  auth: [
    username: System.get_env("INFLUX_USER"),
    password: System.get_env("INFLUX_PASSWORD")
  ],
  database: "brighterlink_io"
