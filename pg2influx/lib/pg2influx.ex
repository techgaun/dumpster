defmodule PG2Influx do
  use Application
  import BrighterlinkIo.DeviceDataDB

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    influx_worker = BrighterlinkIo.InfluxConnection.child_spec
    pg_worker = worker(BrighterlinkIo.DeviceDataDB, [Moebius.get_connection])
    {:ok, pid} = Supervisor.start_link [influx_worker, pg_worker], [strategy: :one_for_one, name: :pg2influx]
    devices = read_devices |> Enum.join(", ")
    query = "select * from devices_data where id in (#{devices}) order by device_timestamp asc;"
    data = query
      |> read_device_data

    data
    |> Enum.each(fn x ->
      write_to_influx(x)
    end)
    {:ok, pid}
  end
end
