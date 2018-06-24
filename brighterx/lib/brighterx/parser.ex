defmodule Brighterx.Parser do
  @moduledoc """
  A parser to parse BrighterLink responses
  """

  @type status_code :: integer
  @type response :: {:ok, [struct]} | {:ok, struct} | :ok | {:error, map, status_code} | {:error, map} | any

  @spec parse(tuple, any) :: Brighterx.response
  def parse(response, module) do
    case response do
      {:ok, %HTTPoison.Response{body: body, headers: _, status_code: status}} when status in [200, 201] ->
        decoded_body =
          case body |> String.starts_with?("[") do
            true ->
              body
              |> Poison.decode!(as: [module.__struct__])
            false ->
              body
              |> Poison.decode!(as: module.__struct__)
          end
        {:ok, decoded_body}

      {:ok, %HTTPoison.Response{body: _, headers: _, status_code: 204}} ->
        :ok

      {:ok, %HTTPoison.Response{body: body, headers: _, status_code: status}} ->
        {:ok, json} = Poison.decode(body)
        {:error, json["errors"], status}

      {:error, %HTTPoison.Error{id: _, reason: reason}} ->
        {:error, %{reason: reason}}
      _ ->
        response
    end
  end
end
