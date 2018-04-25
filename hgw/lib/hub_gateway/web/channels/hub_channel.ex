defmodule HubGateway.Web.HubChannel do
  use HubGateway.Web, :channel
  alias HubGateway.Client.Socket
  alias HubGateway.Web.ChannelWatcher
  alias HubGateway.Helpers.LogUploader
  alias HubGateway.Helpers.ZWave
  require Logger

  @evt_in ~w(c s r rm create)
  @evt_mapping %{
    "c" => "command",
    "s" => "status",
    "r" => "command_rsp",
    "create" => "create",
    "rm" => "remove"
  }

  def join(ident, _payload, socket) do
    :ok = ChannelWatcher.monitor(self(), {__MODULE__, :leave, {ident, socket.assigns.token}})
    {:ok, socket}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("r", %{"t" => "log", "b" => log}, %{topic: ident} = socket) do
    spawn(fn ->
      LogUploader.upload(ident, log, socket.assigns.token)
    end)
    {:noreply, socket}
  end

  def handle_in("s" = event, payload, %{topic: ident} = socket) do
    Logger.warn("received input for event 's' on topic #{inspect socket.topic}: #{inspect payload}")
    status = ZWave.translate_status(ident, payload)
    Logger.warn("'s' event translated to: #{inspect status}")
    case status do
      [] -> nil
      status ->
        c = client(ident)
        Socket.push(c, "hub:" <> socket.topic, @evt_mapping[event], status)
    end
    {:noreply, socket}
  end

  def handle_in("create" = event, payload, %{topic: ident} = socket) do
    Logger.warn("received input for event 'create' on topic #{inspect socket.topic}: #{inspect payload}")
    status = ZWave.translate_create(ident, payload)
    Logger.warn("'create' event translated to: #{inspect status}")
    case status do
      {:error, msg} -> Logger.warn("Error encountered with 'create' payload from hub: #{msg}")
      {:ok, core_payload} ->
        c = client(ident)
        Socket.push(c, "hub:" <> socket.topic, @evt_mapping[event], core_payload)
    end
    {:noreply, socket}
  end

  def handle_in("rm" = event, payload, %{topic: ident} = socket) do
    Logger.warn "received input for event 'rm' on topic #{inspect socket.topic}:#{inspect payload}"
    rm_payload = ZWave.translate_remove(ident, payload)
    Logger.warn "'rm' event translated to: #{inspect rm_payload}"
    case rm_payload do
      {:error, msg} -> Logger.warn "Error : #{inspect msg}"
      {:ok, core_payload} ->
        c = client(ident)
        Socket.push(c, "hub:" <> ident, @evt_mapping[event], core_payload)
    end
    {:noreply, socket}
  end

  def handle_in(event, payload, %{topic: ident} = socket) when event in @evt_in do
    c = client(ident)
    Socket.push(c, "hub:" <> socket.topic, @evt_mapping[event], payload)
    {:noreply, socket}
  end

  def handle_in(event, payload, socket) do
    Logger.error "unhandled event #{event}: with payload #{inspect payload} for #{socket.topic}"
    {:noreply, socket}
  end

  def leave({ident, _token}) do
    Logger.warn inspect "socket closing for #{ident}"
    :ok
  end

  def terminate(_reason, _socket) do
    ChannelWatcher.demonitor(self())
    :ok
  end

  defp client(ident), do: Socket.whereis(ident)
end
