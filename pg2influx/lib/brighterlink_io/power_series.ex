defmodule BrighterlinkIo.PowerSeries do
  use Instream.Series

  series do
    database Application.get_env(:pg2influx, BrighterlinkIo.InfluxConnection)[:database]
    measurement "power"

    tag :device_id

    field :grid
  end
end
