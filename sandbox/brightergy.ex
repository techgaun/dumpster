
defmodule Brightergy do

    def info(:languages), do: {"Elixir", "Python", "Javascript"}
    def info(:frameworks), do: {"Phoenix", "ReactJS"}
    def info(:services), do: {"Heroku", "Runscope", "Postgres", "Honeybadger", "Papertrail", "Intercom", "Auth0"}
    def info(:tools), do: {"GitHub", "Trello", "SemaphoreCI", "InVision", "Slack"}
    def info(:hardware), do: {"Schneider", "Digi", "Zigbee", "eGauge", "Webbox", "Fornius"}
    def info(:methodologies), do: {"Continuous Delivery", "Design Thinking"}
    def info(:brighterlink) do
        {:languages, :frameworks, :services, :tools, :hardware, :methodologies}
        |> Tuple.to_list
        |> Enum.map(fn(x) -> "#{x} = " <> (info(x) |> Tuple.to_list |> Enum.join(",")) end)
        |> Enum.join(" \n")
        |> IO.puts
    end
end

Brightergy.info(:brighterlink)