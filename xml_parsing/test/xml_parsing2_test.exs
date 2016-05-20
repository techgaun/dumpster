defmodule XmlParsing2Test do
  use ExUnit.Case
  doctest XmlParsing

  def hex_to_int(hex) do
    hex |> String.upcase |> Base.decode16! |> :binary.decode_unsigned |> to_string
  end

  def parse_egauge_data(data) do

    # doc = Exml.parse data

    #####Exml#####
    # meta_data = Exml.get(doc, "//data/@*")
    # values = Exml.get(doc, "//data/r") |> Enum.map(fn r -> List.first(r) end)

    # IO.inspect Exml.get(doc, "//data")

    #####Floki#####
    [{_, atts, values} | rest] = Floki.find(data, "data")

    # get attributes
    atts = atts |> Enum.map(fn {name, value} -> 
        case value do
            "0x" <> num -> {name, hex_to_int(num)}
            _ -> {name, value}
        end
    end) |> Enum.into(%{})

    # get first register name
    {_, _, [register_name]} = Floki.find(values, "cname") |> List.first

    # get values for first register name
    values = Floki.find(values, "r") |> Enum.map(fn r -> 
        {_, _, [value]} = Floki.find(r, "c") |> List.first 
        value
    end)

    %{attributes: atts, register: register_name, values: values}
  end

  def get_egauge_data(url) do
    # Digest Auth header for simple implementation is as follows
    # digest=response = md5( md5(username:domain:password):nounce:md5(method:uri) )
    # Sample: %{"Authorization" => 'Digest username="owner", realm="eGauge Administration", nonce="", uri="/cgi-bin/egauge?n=5", response="0d9c0fa2aef29fac6c05788879f88a8d", opaque=""'}
    username = "owner"
    password = "default"
    realm = "eGauge Administration"
    method = "GET"
    uri = "/cgi-bin/egauge-show?S&n=60"
    nonce = ""

    time_start = :os.system_time(:milli_seconds)
    a1 = :crypto.hash(:md5, Enum.join([username, realm, password], ":")) |> Base.encode16 |> String.downcase
    a2 = :crypto.hash(:md5, Enum.join([method, uri], ":")) |> Base.encode16 |> String.downcase
    auth = :crypto.hash(:md5, Enum.join([a1, nonce, a2], ":")) |> Base.encode16 |> String.downcase
    authorization = 'Digest username="#{username}", realm="#{realm}", nonce="#{nonce}", uri="#{uri}", response="#{auth}", opaque=""'
    time_end = :os.system_time(:milli_seconds)

    IO.puts("Auth header: " <> to_string authorization)
    IO.puts("Auth created in " <> (to_string (time_end - time_start)) <> "ms")
    HTTPoison.start
    case HTTPoison.get("#{url}#{uri}", %{"Authorization" => authorization}) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        time_start = :os.system_time(:milli_seconds)
        parsed_data = parse_egauge_data(body)
        time_end = :os.system_time(:milli_seconds)

        IO.puts("Parsed:")
        IO.inspect parsed_data
        IO.puts("Parsed in " <> (to_string (time_end - time_start)) <> "ms")

        {:ok, url}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
        {:error, "#{url} not found"}
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        IO.puts "Unauthorized"
        {:error, "#{url} not authorized"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        {:error, "#{url}: #{reason}"}
    end
  end

  def timed_event do
    ["http://egauge17983.egaug.es", "http://egauge17984.egaug.es", "http://blahblah.egaug.es"]
      |> Enum.map(fn url -> Task.async(fn -> get_egauge_data(url) end).ref end)

    :timer.sleep(5000)

    timed_event()
  end

  test "testing http request with digest auth header" do
    timed_event()
  end
end