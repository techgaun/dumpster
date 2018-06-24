ExUnit.start()

defmodule Brighterx.TestHelpers do
  use ExUnit.Case, async: false
  alias Brighterx.Api
  import Mock

  def fake_response(body, status) when is_atom(body) do
    {:ok, %HTTPoison.Response{body: body, status_code: status}}
  end
  def fake_response(body, status) do
    {:ok, %HTTPoison.Response{body: Poison.encode!(body), status_code: status}}
  end

  def mock(:get, response, func), do: mock([get: fn(_url, _headers) -> response end], func)
  def mock(:post, response, func), do: mock([post: fn(_url, _params, _headers) -> response end], func)
  def mock(:post_data, response, data, func), do: mock([post: fn(_url, params, _headers) -> if data === params, do: response, else: (IO.inspect data ; IO.inspect params ; raise "Params do not match") end], func)
  def mock(:put, response, func), do: mock([put: fn(_url, _params, _headers) -> response end], func)
  def mock(:delete, response, func), do: mock([delete: fn(_url, _headers) -> response end], func)
  def mock(funcl, func) do
    with_mock Api, [:passthrough], funcl do
      func.()
    end
  end
end
