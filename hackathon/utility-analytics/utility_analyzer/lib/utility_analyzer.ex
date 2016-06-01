defmodule UtilityAnalyzer do
  use Application
  import UtilityAnalyzer.Config

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(UtilityAnalyzer.Worker, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :simple_one_for_one, name: UtilityAnalyzer.Supervisor]
    {:ok, sup_pid} = Supervisor.start_link(children, opts)
    src_dir
    |> Path.join("*.pdf")
    |> Path.wildcard
    |> Enum.each(fn fname ->
      require Logger
      Logger.warn inspect "Starting child for #{fname}"
      Logger.warn inspect Supervisor.start_child(sup_pid, [[name: fname]])
    end)
    {:ok, sup_pid}
  end
end
