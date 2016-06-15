defmodule BrighterlinkIo.DeviceDataDB do
  use Moebius.Database
  import Moebius.{DocumentQuery, Database}
  alias BrighterlinkIo.DeviceDataDB, as: Db
  require Logger

  def read_device_data(query) do
    query
    |> Db.run
  end

  def read_devices do
    "select id from devices where type = 'rtm';"
    |> Db.run
    |> Enum.map(fn %{id: id} ->
      id
    end)
  end

  def write_to_influx(row) do
    Logger.warn inspect row
  end
end
