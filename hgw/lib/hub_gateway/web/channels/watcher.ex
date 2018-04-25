defmodule HubGateway.Web.ChannelWatcher do
  @moduledoc """
  A simple watcher to watch and shutdown the upstream socket
  """
  use GenServer
  alias HubGateway.Client.Socket
  require Logger

  @watcher_name :casa_channel_watcher

  def watcher_name, do: @watcher_name

  def monitor(pid, mfa) do
    GenServer.call(@watcher_name, {:monitor, pid, mfa})
  end

  def demonitor(pid) do
    GenServer.call(@watcher_name, {:demonitor, pid})
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{channels: %{}}}
  end

  def handle_call({:monitor, pid, {_, _, {ident, token}} = mfa}, _from, state) do
    start_upstream_socket(ident, token)
    Process.link(pid)
    {:reply, :ok, put_channel(state, pid, mfa)}
  end

  def handle_call({:demonitor, pid}, _from, state) do
    case Map.fetch(state.channels, pid) do
      :error       -> {:reply, :ok, state}
      {:ok,  _mfa} ->
        Process.unlink(pid)
        {:reply, :ok, drop_channel(state, pid)}
    end
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    case Map.fetch(state.channels, pid) do
      :error -> {:noreply, state}
      {:ok, {mod, func, args}} ->
        Task.start_link(fn -> apply(mod, func, [args]) end)
        {:noreply, drop_channel(state, pid)}
    end
  end

  defp drop_channel(state, pid) do
    case Map.fetch(state.channels, pid) do
      {:ok, {_, _, {ident, _}}} ->
        unless Socket.whereis(ident) == :undefined, do: Socket.shutdown(ident)
        %{state | channels: Map.delete(state.channels, pid)}
      _ -> state
    end
  end

  defp put_channel(state, pid, mfa) do
    %{state | channels: Map.put(state.channels, pid, mfa)}
  end

  defp start_upstream_socket(ident, token) do
    case Socket.whereis(ident) do
      :undefined ->
        {:ok, _pid} = Socket.start_link(%{token: token, identifier: ident})
      _pid ->
        Logger.debug "upstream socket already running"
    end
  end
end
