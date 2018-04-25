defmodule HubGateway.Client.Socket do
  @moduledoc """
  This module implements a phoenix client to work with casaiq backend channels for hub
  """
  require Logger
  alias Phoenix.Channels.GenSocketClient
  alias HubGateway.Web.Endpoint

  @behaviour GenSocketClient
  @ping_timeout 45 # to work with 48s timeout, little less value

  @type socket_params :: map

  @doc """
  The params is a map that consists of token and various other socket options.
  `params` is later merged onto the genserver state and is available as `params` key in state.

  ## Example

      iex> {:ok, pid} = __MODULE__.start_link(%{token: "jwt_token", identifier: "device_ident"})
  """
  @spec start_link(socket_params) :: {:ok, pid}
  def start_link(params) do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      params,
      params[:sock_opts] || [],
      name: via_tuple(params[:identifier])
    )
  end

  def push(pid, topic, event, payload) do
    send(pid, {:push, topic, event, payload})
  end

  def shutdown(ident) do
    GenServer.stop(via_tuple(ident), :normal)
  end

  def init(params) do
    # Process.flag(:trap_exit, true)
    topic = "hub:#{params[:identifier]}"
    {:connect, build_url(params[:token]), %{topic: topic, first_join: true, ping_ref: 1, params: params}}
  end

  def handle_connected(transport, state) do
    Logger.info("connected")
    {:ok, _ref} = GenSocketClient.join(transport, state[:topic])
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    Logger.error("disconnected: #{inspect reason} with state -> #{inspect state}")
    case reason do
      {:error, {403, _}} ->
        {:stop, :normal, state}
      _ ->
        Process.send_after(self(), :connect, :timer.seconds(1))
        {:ok, state}
    end
  end

  def handle_joined(topic, _payload, _transport, state) do
    Logger.info("joined the topic #{topic}")

    if state.first_join do
      :timer.send_interval(:timer.seconds(@ping_timeout), self(), :ping_server)
      {:ok, %{state | first_join: false, ping_ref: 1}}
    else
      {:ok, %{state | ping_ref: 1}}
    end
  end

  def handle_join_error(topic, payload, _transport, state) do
    Logger.error("join error on the topic #{topic}: #{inspect payload} with state -> #{inspect state}")
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    Logger.error("disconnected from the topic #{topic}: #{inspect payload} with state -> #{inspect state}")
    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

  def handle_message("hub:" <> topic, "command", payload, _trasport, state) do
    Logger.warn("command on topic #{topic}: #{inspect payload}")
    case HubGateway.Helpers.ZWave.translate_command(payload) do
      {:ok, command} ->
        Logger.warn("command on #{topic} translated to #{inspect command}")
        Endpoint.broadcast! topic, "c", command
      {:error, msg} ->
        push(self(), "hub:" <> topic, "command_rsp", %{error: msg})
    end

    # do something here later for server-side
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    Logger.warn("message on topic #{topic}: #{event} #{inspect payload}")
    {:ok, state}
  end

  def handle_reply("ping", _ref, %{"status" => "ok"} = payload, _transport, state) do
    Logger.info("server pong ##{payload["response"]["ping_ref"]}")
    {:ok, state}
  end
  def handle_reply(topic, _ref, payload, _transport, state) do
    Logger.warn("reply on topic #{topic}: #{inspect payload}")
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting with state -> #{inspect state}")
    {:connect, state}
  end
  def handle_info({:join, topic}, transport, state) do
    Logger.info("joining the topic #{topic}")
    case GenSocketClient.join(transport, topic) do
      {:error, reason} ->
        Logger.error("error joining the topic #{topic}: #{inspect reason}")
        Process.send_after(self(), {:join, topic}, :timer.seconds(1))
      {:ok, _ref} -> :ok
    end

    {:ok, state}
  end
  def handle_info(:ping_server, transport, state) do
    Logger.info("sending ping ##{state.ping_ref}")
    GenSocketClient.push(transport, state[:topic], "ping", %{ping_ref: state.ping_ref})
    {:ok, %{state | ping_ref: state.ping_ref + 1}}
  end
  def handle_info({:push, topic, event, payload}, transport, state) do
    Logger.debug("Pushing to #{topic} - #{event} with payload -> #{inspect payload}")
    GenSocketClient.push(transport, topic, event, payload)
    {:ok, state}
  end
  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled message #{inspect message}")
    {:ok, state}
  end

  defp build_url(token) do
    "#{Application.get_env(:hub_gateway, :ws_server)}?token=#{token}"
  end

  defp via_tuple(ident) do
    {:via, :gproc, {:n, :l, {:identifier, ident}}}
  end

  @doc """
      iex> HubGateway.Client.Socket.whereis("location:ee5b29f3-7b1f-4fba-9892-73969fd33f40")
  """
  def whereis(ident) do
    :gproc.whereis_name({:n, :l, {:identifier, ident}})
  end
end
