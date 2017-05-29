defmodule SrvProc do
  def start(module) do
    spawn(fn ->
      initial_state = module.init()
      loop(module, initial_state)
    end)
  end

  def call(pid, req) do
    send(pid, {:call, req, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, req) do
    send(pid, {:cast, req})
  end

  def loop(module, state) do
    new_state = 
      receive do
        {:call, req, caller} ->
          {resp, new_state } = module.handle_call(req, state)
          send(caller, {:response, resp})
          new_state
        {:cast, req} ->
          module.handle_cast(req, state)
      end

    loop(module, new_state)
  end
end

defmodule KVStore do
  def init, do: Map.new()

  def handle_cast({:put, k, v}, state) do
    Map.put(state, k, v)
  end

  def handle_call({:get, key}, state) do
    {Map.fetch(state, key), state}
  end
end
