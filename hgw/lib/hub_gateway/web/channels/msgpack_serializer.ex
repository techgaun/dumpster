defmodule HubGateway.MsgpackSerializer do
  @moduledoc """
  A basic msgpack serializer that uses msgpack for serializing messages
  for phoenix for use with hub gateway clients
  """
  alias Phoenix.Transports.Serializer
  alias Phoenix.Socket.{Reply, Message, Broadcast}
  @behaviour Serializer

  @gzip_threshold 1400

  def fastlane!(%Broadcast{} = msg) do
    {:socket_push, :binary, do_pack(%Message{
      topic: msg.topic,
      event: msg.event,
      payload: msg.payload,
    })}
  end

  def encode!(%Reply{} = reply) do
    {:socket_push, :binary, do_pack(%Message{
      topic: reply.topic,
      event: "phx_reply",
      ref: reply.ref,
      join_ref: reply.join_ref,
      payload: %{status: reply.status, response: reply.payload}
    })}
  end

  def encode!(%Message{} = msg) do
    {:socket_push, :binary, do_pack(msg)}
  end

  def decode!(msg, _opts) do
    msg
    |> Msgpax.unpack!()
    |> Message.from_map!()
  end

  defp do_pack(%Message{} = msg) do
    msg = msg
          |> Map.from_struct
          |> Msgpax.pack!
    maybe_gzip(msg, :erlang.iolist_size(msg))
  end

  defp maybe_gzip(data, size) when size < @gzip_threshold, do: data
  defp maybe_gzip(data, _), do: :zlib.gzip(data)
end
