# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :hub_gateway, HubGateway.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MyRrek3wcpUxHYUIf5GUVGg48Z9HDKZ72ThmSJgQWrQboXox6Ec5zwfNsjrUXCmw",
  render_errors: [view: HubGateway.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: HubGateway.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :hub_gateway,
  api_server: System.get_env("API_SERVER") || "https://api-stage.casa.iq/api",
  ws_server: System.get_env("WS_SERVER") || "wss://api-stage.casa.iq/ws/websocket"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: Mix.env,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!,
  included_environments: ~w(prod review stage)a,
  use_error_logger: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
