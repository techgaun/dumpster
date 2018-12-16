defmodule Hub do
  @base_url "https://api.github.com"
  @username "techgaun"

  HTTPoison.start()

  "#{@base_url}/users/#{@username}/repos"
  |> HTTPoison.get!()
  |> Map.get(:body)
  |> Jason.decode!()
  |> Enum.each(fn repo ->
    def unquote(String.to_atom(repo["name"]))() do
      unquote(Macro.escape(repo))
    end
  end)

  def go(repo) do
    url = apply(__MODULE__, repo, [])["html_url"]
    IO.puts "Launching browser to #{url}"
    System.cmd "xdg-open", [url]
  end
end
