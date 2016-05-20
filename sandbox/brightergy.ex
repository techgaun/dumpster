defmodule Brightergy do

    def info do
        {:language, :services, :tools}
        |> Tuple.to_list
        |> Enum.map(fn x -> info(x) |> Tuple.to_list |> Enum.join(",") end)
        |> Enum.join(" | ")
        |> IO.puts
    end

    def info(:language) do
        {"Elixir", "Phoenix", "Python", "ReactJS"}
    end

    def info(:services) do
        {"Heroku", "Runscope", "Postgres", "Honeybadger", "Papertrail", "Intercom", "Auth0"}
    end

    def info(:tools) do
        {"GitHub", "Trello", "SemaphoreCI", "InVision", "Slack"}
    end
end

Brightergy.info