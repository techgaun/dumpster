defmodule HubGateway.MsgpackSerializerTest do
  use ExUnit.Case

  alias HubGateway.MsgpackSerializer
  alias Phoenix.Socket.{Broadcast, Message, Reply}

  @msg_packed [<<133>>, [[<<165>> | "event"], <<161>> | "e"], [[<<168>> | "join_ref"] | <<192>>], [[<<167>> | "payload"], <<164>> | "test"], [[<<163>> | "ref"] | <<192>>], [[<<165>> | "topic"], <<161>> | "t"]]


  test "fastlane!/1 does proper packing" do
    msg = %Broadcast{topic: "t", event: "e", payload: "test"}
    assert MsgpackSerializer.fastlane!(msg) == {:socket_push, :binary, @msg_packed}

    msg = %{msg | payload: Enum.to_list(1..2000)}
    raw_packed = msg |> Map.from_struct |> Msgpax.pack!
    {:socket_push, :binary, gzipped} = MsgpackSerializer.fastlane!(msg)
    assert byte_size(gzipped) < :erlang.iolist_size(raw_packed)
    <<31, 139>> <> _ = gzipped
  end

  test "encode!/1 encodes %Reply{} correctly" do
    reply = %Reply{topic: "t", ref: "hello", status: "ok", payload: %{"msg": "ok"}}
    packed = [<<133>>, [[<<165>> | "event"], <<169>> | "phx_reply"], [[<<168>> | "join_ref"] | <<192>>], [[<<167>> | "payload"], <<130>>, [[<<168>> | "response"], <<129>>, [[<<163>> | "msg"], <<162>> | "ok"]], [[<<166>> | "status"], <<162>> | "ok"]], [[<<163>> | "ref"], <<165>> | "hello"], [[<<165>> | "topic"], <<161>> | "t"]]
    assert MsgpackSerializer.encode!(reply) == {:socket_push, :binary, packed}
  end

  test "encode!/1 encodes %Message{} correctly" do
    msg = %Message{topic: "t", event: "e", payload: "test"}
    assert MsgpackSerializer.encode!(msg) == {:socket_push, :binary, @msg_packed}
  end

  test "decode!/2 decodes correctly" do
    assert %Message{topic: "t", event: "e", payload: "test"} == MsgpackSerializer.decode!(@msg_packed, [])
  end
end
