defmodule BrighterlinkIo.DeviceDataDB do
  use Moebius.Database
  import Moebius.{DocumentQuery, Database}
  alias BrighterlinkIo.DeviceDataDB, as: Db
  alias BrighterlinkIo.{PowerSeries, InfluxConnection}
  require Logger

  def db_query(query) do
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
    timestamp = row.device_timestamp
      |> datetime_to_ts

    unless row.data["Grid"] |> is_nil do
      row.data["Grid"]
      |> prewarm_data(timestamp)
      |> Enum.each(fn {ts, val} ->
        data = %PowerSeries{
          timestamp: ts,
          tags: %PowerSeries.Tags{
            device_id: row.device_id
          },
          fields: %PowerSeries.Fields{
            grid: val
          }
        }

        data
        |> InfluxConnection.write(
          [
            async: true,
            precision: :seconds
          ]
        )
      end)
    end
  end

  def prewarm_data(lst, start_ts) do
    count = lst |> Enum.count
    0..count
    |> Enum.map(fn x ->
      x + start_ts
    end)
    |> Enum.to_list
    |> Enum.zip(lst)
  end

  @doc """
  Convert yyyy-mm-dd hh:mm:ss to unix timestamp
  """
  def datetime_to_ts(dt) do
    [h | t] = Regex.run(~r/(\d{4})-(\d{1,2})-(\d{1,2})\s(\d{1,2}):(\d{1,2}):(\d{1,2})/, dt)
    dt = t
      |> Enum.map(fn x ->
        String.to_integer(x)
      end)
      |> Enum.chunk(3)
      |> Enum.map(fn x ->
        List.to_tuple(x)
      end)
      |> List.to_tuple
    :calendar.datetime_to_gregorian_seconds(dt)
    |> Kernel.-(62167219200)
  end
end
