defmodule BrighterlinkIo.PowerSeries do
  use Instream.Series

  series do
    database "brighterlink_io"
    measurement "power"

    tag :device_id

    field :grid
  end
end
