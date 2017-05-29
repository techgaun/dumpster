defmodule TodoServer do
  def start do
    pid = spawn(fn -> loop(TodoList.new) end)
    Process.register(pid, :todo_server)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})
    receive do
      {:entries, entries} -> {:ok, entries}
      after 5_000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      msg -> handle_msg(todo_list, msg)
    end
    loop(new_todo_list)
  end

  def handle_msg(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def handle_msg(todo_list, {:entries, caller, date}) do
    send(caller, {:entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

defmodule TodoList do
  def new, do: []

  def add_entry(todo_list, new_entry), do: [new_entry | todo_list]

  def entries(todo_list, date) do
    todo_list
    |> Enum.filter(fn %{date: d} -> d == date end)
  end
end
