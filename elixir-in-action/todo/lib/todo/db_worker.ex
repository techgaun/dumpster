defmodule Todo.DBWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def init(db_folder) do
    File.mkdir_p!(db_folder)
    {:ok, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data = case File.read(filename(db_folder, key)) do
      {:ok, content} -> :erlang.binary_to_term(content)
      _ -> nil
    end
    {:reply, data, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    db_folder
    |> filename(key)
    |> File.write!(:erlang.term_to_binary(data))
    {:noreply, db_folder}
  end

  defp filename(db_folder, key), do: "#{db_folder}/#{key}"
end
