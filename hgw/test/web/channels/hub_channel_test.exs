defmodule HubGateway.Web.HubChannelTest do
  use HubGateway.Web.ChannelCase, async: false
  alias HubGateway.Web.HubChannel
  alias HubGateway.Client.Socket, as: ClientSocket
  alias HubGateway.Helpers.LogUploader
  import Mock
  import ExUnit.CaptureLog
  require Logger

  setup do
    socket = socket("ws", %{token: "faketoken"})

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, "hub:fake1")
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, "hub:fake2")
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  test "create/status events work properly", %{socket: socket} do
    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, "hub:fake3")
    with_mock ClientSocket,
      [whereis: fn _-> :ok end, push: fn _, _, _, _ -> :ok end, shutdown: fn _ -> :ok end] do
      ref = push socket, "create", %{"t" => [0x26], "m" => "Some model", "n" => 24}
      refute_reply ref, :ok, %{msg: "ok"}
    end
  end

  test "remove events work properly", %{socket: socket} do
    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, "hub:fake3")
    with_mock ClientSocket,
      [whereis: fn _-> :ok end, push: fn _, _, _, _ -> :ok end, shutdown: fn _ -> :ok end] do
      ref = push socket, "rm", %{"n" => 24}
      refute_reply ref, :ok, %{msg: "ok"}

      ref = push socket, "rm", %{}
      refute_reply ref, :ok, %{msg: "ok"}
    end
  end

  test "leaving the channel demonitors properly", %{socket: socket} do
    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, "hub:fake4")
    ref = leave(socket)
    assert_reply ref, :ok
  end

  test "log uploading is called when log params come in", %{socket: socket} do
    ident = "lo:gu:pl:oa:de:rr"
    with_mock LogUploader, [upload: fn _, _, _ -> :ok end] do
      {:ok, _, socket} = subscribe_and_join(socket, HubChannel, ident)
      ref = push socket, "r", %{"t" => "log", "b" => "some_log"}
      refute_reply ref, :ok, %{msg: "ok"}
    end
  end

  test "status creation works as expected with appropriate keys", %{socket: socket} do
    ident = "st:at:us:te:st:er"
    status = %{
      "ts" => System.system_time(:second),
      "n" => 2,
      "Mode" => "Auto"
    }

    log_level = Logger.level
    Logger.configure(level: :debug)

    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, ident)
    fun = fn ->
      ref = push socket, "s", status
      refute_reply ref, :ok, %{msg: "ok"}
    end
    log = capture_log(fun)
    assert log =~ ident
    assert log =~ "#{ident}_#{status["n"]}"
    assert log =~ ~S("system_mode" => "auto")
    Logger.configure(level: log_level)
  end

  test "device creation logs error as expected for bad format", %{socket: socket} do
    ident = "de:vi:ce:cr:ea:te"
    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, ident)
    fun = fn ->
      ref = push socket, "create", %{"n" => 2, "m" => "hello", "t" => [-1]}
      refute_reply ref, :ok, %{msg: "ok"}
    end
    log = capture_log(fun)
    assert log =~ "Error encountered with 'create'"
  end

  test "normal known events are passed to upstream", %{socket: socket} do
    ident = "kn:ow:ne:ve:nt:00"
    log_level = Logger.level
    Logger.configure(level: :debug)
    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, ident)
    fun = fn ->
      push socket, "r", %{}
    end
    log = capture_log(fun)
    assert log =~ ident
    assert log =~ "command_rsp"
    Logger.configure(level: log_level)
  end

  test "unhandled event is logged properly for our analysis", %{socket: socket} do
    ident = "ba:de:ve:nt"
    {:ok, _, socket} = subscribe_and_join(socket, HubChannel, ident)
    fun = fn ->
      ref = push socket, "invalid", %{}
      refute_reply ref, :ok, %{msg: "ok"}
    end
    log = capture_log(fun)
    assert log =~ "invalid"
    assert log =~ "for #{ident}"
  end
end
