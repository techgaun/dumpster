defmodule SalesforceData do
  use Application
  alias SalesforceData.Repo

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(SalesforceData.Worker, [arg1, arg2, arg3]),
      supervisor(Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SalesforceData.Supervisor]
    {:ok, sup_id} = Supervisor.start_link(children, opts)

    SalesforceData.Parser.parse_data

    {:ok, sup_id}
  end
end
