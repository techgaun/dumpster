defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :db_server)
  end

  def store(key, data) do
    GenServer.cast(get_worker(key), {:store, key, data})
  end

  def get(key) do
    GenServer.call(get_worker(key), {:get, key})
  end

  def get_worker(key) do
    idx = :erlang.phash2(key, 3)
    GenServer.call(:db_server, {:worker_id, idx})
  end

  def init(db_folder) do
    send(self(), :start_workers)
    {:ok, {db_folder, %{}}}
  end

  def handle_info(:start_workers, {db_folder, _workers}) do
    workers =
      0..2
      |> Enum.map(fn id ->
        {:ok, pid} = Todo.DBWorker.start(db_folder)
        {id, pid}
      end)
      |> Enum.into(%{})

    {:noreply, {db_folder, workers}}
  end

  def handle_call({:worker_id, idx}, _, {db_folder, workers}) do
    {:reply, workers[idx], {db_folder, workers}}
  end
end
