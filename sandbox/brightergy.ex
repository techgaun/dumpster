defmodule Brightergy do

    def info(:languages), do: {"Elixir", "Python", "Javascript"}
    def info(:frameworks), do: {"Phoenix", "ReactJS"}
    def info(:datastore), do: {"Postgres", "InfluxDB"}
    def info(:services), do: {"Heroku", "Runscope", "Postgres", "Honeybadger", "Papertrail", "Intercom", "Auth0"}
    def info(:tools), do: {"GitHub", "Trello", "SemaphoreCI", "InVision", "Slack"}
    def info(:hardware), do: {"Schneider", "Digi", "Zigbee", "eGauge", "Webbox", "Fornius"}
    def info(:methodologies), do: {"Continuous Delivery", "Design Thinking", "Mobile First"}
    def info(:brighterlink = type) when is_atom(type) do
        {:languages, :frameworks, :datastore, :services, :tools, :hardware, :methodologies}
        |> Tuple.to_list
        |> Enum.map(fn(x) -> "#{x} = " <> (info(x) |> Tuple.to_list |> Enum.join(",")) end)
        |> Enum.join("\n")
        |> IO.puts
    end
    def info(type), do: "Sorry, we don't do that" |> IO.puts
end

Brightergy.info(:brighterlink)