defmodule BrighterlinkIo.InfluxConnection do
  use Instream.Connection, otp_app: :pg2influx
end
