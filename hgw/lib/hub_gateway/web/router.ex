defmodule HubGateway.Web.Router do
  use HubGateway.Web, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HubGateway.Web do
    pipe_through :api
  end
end
