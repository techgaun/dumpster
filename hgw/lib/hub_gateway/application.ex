defmodule HubGateway.Application do
  use Application
  alias HubGateway.Web.{Endpoint, ChannelWatcher}

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec
    runtime_loglevel()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Endpoint, []),
      worker(ChannelWatcher, [ChannelWatcher.watcher_name])
      # Start your own worker by calling: HubGateway.Worker.start_link(arg1, arg2, arg3)
      # worker(HubGateway.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HubGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp runtime_loglevel do
    sys_log_level = System.get_env("LOG_LEVEL")

    if sys_log_level in ["debug", "info", "warn", "error"] do
      Logger.configure(level: String.to_atom(sys_log_level))
    end
  end
end
