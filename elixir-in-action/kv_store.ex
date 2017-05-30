defmodule KVStore do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, [], name: :kv_store)
  end

  def put(k, v) do
    GenServer.cast(:kv_store, {:put, k, v})
  end

  def get(k) do
    GenServer.call(:kv_store, {:get, k})
  end

  def init(_) do
    :timer.send_interval(5_000, :cleanup)
    {:ok, Map.new()}
  end

  def handle_cast({:put, k, v}, state) do
    {:noreply, Map.put(state, k, v)}
  end

  def handle_call({:get, k}, _, state) do
    {:reply, Map.fetch(state, k), state}
  end

  def handle_info(:cleanup, state) do
    IO.puts "Performing cleanup"
    {:noreply, state}
  end
end
