defmodule Brighterx.Api do
  @moduledoc """
  API interface to communicate with brighterlink-io api

  Todo: refactor code so that we can move auth part to single place
  """

  use HTTPoison.Base
  alias Brighterx.Parser
  alias Brighterx.Resources.{Company, Facility, Device}
  alias __MODULE__

  @user_agent [{"User-agent", "Brighterx"}]
  @content_type [{"Content-Type", "application/json"}]

  @doc """
  Creating URL based on url from config and resources paths
  """
  @spec process_url(String.t) :: String.t
  def process_url(path) do
    "#{url}#{path}"
  end

  @doc """
  Wrapper for GET requests

  Example
  - Brighterx.Api.find(Brighterx.Resources.Company, [params: %{name: "Brightergy"}])

  - A tuple of {:ok, [%Brighterx.Resource.<ResourceType>{}]} is returned for successful requests
  - For http status code 204, a :ok atom is returned indicating the request was fulfilled successfully
    but no response body i.e. message-body
  - For all other errors, a tuple of {:ok, <error_detail_map>, status_code} is returned
  """
  @spec find(any, list) :: Brighterx.response
  def find(module, opts \\ []) do
    id = opts[:id] || nil
    params = opts[:params] || %{}
    token = System.get_env("JWT")
    req_header = request_header(%{token: token})
    module
    |> build_url(id, params)
    |> Api.get(req_header)
    |> Parser.parse(module)
  end

  @doc """
  Wrapper for POST requests

  Examples
  - Brighterx.Api.create(Brighterx.Resources.Device, %{name: "Test Thermostat", identifier: "00:01", facility_id: 1, type: "thermostat"})
  - Brighterx.Api.create(Brighterx.Resources.Company, "{\"name\": \"Samar\"}")
  """
  @spec create(any, map, list) :: Brighterx.response
  def create(module, post_data, _opts \\ []) do
    token = System.get_env("JWT")
    req_header = request_header_content_type(%{token: token})
    if post_data |> is_map do
      post_data = Poison.encode!(post_data)
    end
    module
    |> build_url(nil, %{})
    |> Api.post(post_data, req_header)
    |> Parser.parse(module)
  end

  @doc """
  Wrapper for PUT requests

  Examples
  With body as map
  - Brighterx.Api.update(Brighterx.Resources.Device, 1, %{name: "7th floor south"})

  With body as JSON string
  - Brighterx.Api.update(Brighterx.Resources.Device, 1, "{\"name\": \"7th Floor West\"}")
  """
  @spec update(any, integer, map) :: Brighterx.response
  def update(module, id, put_data) do
    token = System.get_env("JWT")
    req_header = request_header_content_type(%{token: token})
    if put_data |> is_map do
      put_data = Poison.encode!(put_data)
    end

    module
    |> build_url(id, %{})
    |> Api.put(put_data, req_header)
    |> Parser.parse(module)
  end

  @doc """
  Wrapper for DELETE requests

  Examples
  - Brighterx.Api.delete(Brighterx.Resources.Device, 1)
  """
  @spec find(any, list) :: Brighterx.response
  def remove(module, id, _opts \\ []) do
    token = System.get_env("JWT")
    req_header = request_header(%{token: token})
    module
    |> build_url(id)
    |> Api.delete(req_header)
    |> Parser.parse(module)
  end

  @doc """
  Convenience function to get company by id or name

  Examples
  - Brighterx.Api.get_company(1)
  - Brighterx.Api.get_company("Brightergy")
  """
  @spec get_company(integer) :: Brighterx.response
  def get_company(id) when is_integer(id), do: find(Company, [id: id])
  @spec get_company(String.t) :: Brighterx.response
  def get_company(name) when is_bitstring(name), do: find(Company, [params: %{name: name}])
  @spec create_company(map) :: Brighterx.response
  def create_company(data), do: create(Company, data)

  @doc """
  Convenience function to get facility by id or name

  Examples
  - Brighterx.Api.get_facility(1)
  - Brighterx.Api.get_facility("Main Office")
  """
  @spec get_facility(integer) :: Brighterx.response
  def get_facility(id) when is_integer(id), do: find(Facility, [id: id])
  @spec get_facility(String.t) :: Brighterx.response
  def get_facility(name) when is_bitstring(name), do: find(Facility, [params: %{name: name}])
  @spec create_facility(integer, map) :: Brighterx.response
  def create_facility(company_id, data), do: create(Facility, Map.merge(data, %{company_id: company_id}))

  @doc """
  Convenience function to get devices by id or name

  Examples
  - Brighterx.Api.get_device(1)
  - Brighterx.Api.get_device("00:01:02:03:04:de:f0:cc")
  """
  @spec get_device(integer) :: Brighterx.response
  def get_device(id) when is_integer(id), do: find(Device, [id: id])
  @spec get_device(String.t) :: Brighterx.response
  def get_device(identifier) when is_bitstring(identifier), do: find(Device, [params: %{identifier: identifier}])
  @spec update_device(integer, map) :: Brighterx.response
  def update_device(id, params) when is_integer(id), do: update(Device, id, params)
  @spec create_device(map) :: Brighterx.response
  def create_device(params) when map_size(params) > 0, do: create(Device, params)

  @doc """
  Builds URL based on the resource, id and parameters
  """
  @spec build_url(any, integer, map) :: String.t
  def build_url(module, id, params \\ %{}) do
    "Elixir.Brighterx.Resources." <> module_str = module
      |> to_string
    resource_path =
      case module_str do
        "Company" ->
          "companies"
        "Facility" ->
          "facilities"
        "Device" ->
          "devices"
        _ ->
          raise ArgumentError, "Unknown resource type. Make sure you are requesting correct resource"
      end
    resource_path = if id |> is_integer, do: "#{resource_path}/#{id}", else: resource_path
    "/api/#{resource_path}?#{URI.encode_query(params)}"
  end

  def url, do: url(System.get_env("BRIGHTERX_ENV") || Mix.env)
  def url(:dev), do: "http://localhost:4001"
  def url(:stage), do: "https://brighterlink-api-stage.herokuapp.com"
  def url(:prod), do: "https://api.brighterlink.io"
  def url(env) when not is_nil(env) and is_bitstring(env), do: url(String.to_atom(env))
  def url(_), do: url(:stage)

  @doc """
  Add authorization header which is basically a JWT token
  and also the user agent
  """
  def request_header(%{token: token}, headers), do: headers ++ [{"Authorization", "Bearer #{token}"}]
  def request_header(opts), do: request_header(opts, @user_agent)
  def request_header_content_type(opts), do: @content_type ++ request_header(opts)
end
