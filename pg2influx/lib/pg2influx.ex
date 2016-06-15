defmodule PG2Influx do
  use Application
  import BrighterlinkIo.DeviceDataDB

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    influx_worker = BrighterlinkIo.InfluxConnection.child_spec
    pg_worker = worker(BrighterlinkIo.DeviceDataDB, [Moebius.get_connection])
    {:ok, pid} = Supervisor.start_link [influx_worker, pg_worker], [strategy: :one_for_one, name: :pg2influx]
    devices = read_devices |> Enum.join(", ")
    count_query = "select count(id) as data_count from devices_data where id in (#{devices});"
    [%{data_count: devices_data_count}] = count_query
      |> db_query
    offset = if devices_data_count > 1000, do: devices_data_count - 1000, else: 0
    loop_query(devices, 1000, offset)
    {:ok, pid}
  end

  def loop_query(devices, limit, 0) do
    query = "select * from devices_data where id in (#{devices}) order by device_timestamp asc limit #{limit} offset #{0};"
    execute_migration(query)
  end
  def loop_query(devices, limit, offset) do
    require Logger
    Logger.warn inspect offset
    query = "select * from devices_data where id in (#{devices}) order by device_timestamp asc limit #{limit} offset #{offset};"
    execute_migration(query)
    if offset <= limit do
      limit = offset
      offset = 0
    else
      offset = offset - limit
    end
    loop_query(devices, limit, offset)
  end
  def execute_migration(query) do
    data = query
      |> db_query

    data
    |> Enum.each(fn x ->
      write_to_influx(x)
    end)
  end
end
