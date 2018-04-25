defmodule HubGateway.Web.ChannelWatcherTest do
  use ExUnit.Case, async: false
  alias HubGateway.Web.ChannelWatcher
  import ExUnit.CaptureLog
  require Logger

  test "channel watcher responds properly for non-existing pid" do
    pid = spawn(fn -> :ok end)
    :timer.sleep(10)
    assert :ok = ChannelWatcher.demonitor(pid)
  end

  test "channel watcher state responds properly for non-registered pid" do
    pid = spawn(fn -> :timer.sleep(10) end)
    ChannelWatcher.monitor(pid, {HubGateway.Web.HubChannel, :leave, {"hello", "hello"}})
    # re-run monitoring to see what happens for upstream socket
    
    log_level = Logger.level
    Logger.configure(level: :debug)
    assert capture_log(fn -> ChannelWatcher.monitor(pid, {HubGateway.Web.HubChannel, :leave, {"hello", "hello"}}) end) =~ "upstream socket already running"
    :timer.sleep(50)
    assert :ok = ChannelWatcher.demonitor(pid)
    Logger.configure(level: log_level)
  end
end
