defmodule BrighterxApiTest do
  use ExUnit.Case
  alias Brighterx.Api
  import Brighterx.TestHelpers
  doctest Brighterx

  setup do
    # delete the BRIGHTERX_ENV
    System.delete_env("BRIGHTERX_ENV")
  end

  test "find should return the resources that exist" do
    response = fake_response(%{id: 1, name: "Sam Apt"}, 200)
    mock :get, response, fn ->
      assert {:ok, %Brighterx.Resources.Facility{id: 1, name: "Sam Apt"}} === Api.find(Brighterx.Resources.Facility)
    end

    response = fake_response([%{id: 1, name: "Sam Apt"}, %{id: 2, name: "Bruce Apt"}], 200)
    mock :get, response, fn ->
      assert {:ok, [%Brighterx.Resources.Facility{id: 1, name: "Sam Apt"}, %Brighterx.Resources.Facility{id: 2, name: "Bruce Apt"}]} === Api.find(Brighterx.Resources.Facility)
    end

    response = fake_response(%{errors: %{"detail" => "unauthorized"}}, 401)
    mock :get, response, fn ->
      assert {:error, %{"detail" => "unauthorized"}, 401} === Api.find(Brighterx.Resources.Facility)
    end

    response = fake_response(%{id: 1, name: "Brightergy Digi"}, 200)
    mock :get, response, fn ->
      assert {:ok, %Brighterx.Resources.Device{id: 1, name: "Brightergy Digi"}} === Api.find(Brighterx.Resources.Device, [id: 1])
      assert {:ok, %Brighterx.Resources.Device{id: 1, name: "Brightergy Digi"}} === Api.find(Brighterx.Resources.Device, [params: %{name: "Brightergy"}])
    end
  end

  test "create should handle request correctly" do
    response = fake_response(%{id: 10}, 201)
    mock :post, response, fn ->
      assert {:ok, %Brighterx.Resources.Company{id: 10}} === Api.create(Brighterx.Resources.Company, %{name: "Sam Comp"})
    end
  end

  test "create_company should handle request correctly" do
    response = fake_response(%{id: 10}, 201)
    mock :post, response, fn ->
      assert {:ok, %Brighterx.Resources.Company{id: 10}} === Api.create_company(%{name: "Sam Comp"})
    end
  end

  test "update should handle request correctly" do
    response = fake_response(%{id: 10, name: "XYZ"}, 200)
    mock :put, response, fn ->
      assert {:ok, %Brighterx.Resources.Company{id: 10, name: "XYZ"}} === Api.update(Brighterx.Resources.Company, 10, %{name: "XYZ"})
    end
  end

  test "Unknown resource type should raise error" do
    error =
      assert_raise ArgumentError, fn ->
        Api.find(Brighterx.Resources.Invalid)
      end
    assert error.message === "Unknown resource type. Make sure you are requesting correct resource"
  end

  test "remove works correctly" do
    response = fake_response(:ok, 204)
    mock :delete, response, fn ->
      assert :ok === Api.remove(Brighterx.Resources.Company, 1)
    end
  end

  test "Unknown response is handled correctly" do
    response = %{unknown: :notvalid}
    mock :get, response, fn ->
      assert Api.find(Brighterx.Resources.Company) === %{unknown: :notvalid}
    end
  end

  test "get_company works correctly" do
    response = fake_response(%{id: 1, name: "Brightergy"}, 200)
    mock :get, response, fn ->
      assert {:ok, %Brighterx.Resources.Company{id: 1, name: "Brightergy"}} === Api.get_company(1)
      assert {:ok, %Brighterx.Resources.Company{id: 1, name: "Brightergy"}} === Api.get_company("Brightergy")
      refute {:ok, %Brighterx.Resources.Company{id: 1, name: "Abc"}} === Api.get_company("Brightergy")
    end
  end

  test "get_facility works correctly" do
    response = fake_response(%{id: 1, name: "Sam Apt"}, 200)
    mock :get, response, fn ->
      assert {:ok, %Brighterx.Resources.Facility{id: 1, name: "Sam Apt"}} === Api.get_facility(1)
      assert {:ok, %Brighterx.Resources.Facility{id: 1, name: "Sam Apt"}} === Api.get_facility("Sam")
    end
  end

  test "create_facility works correctly" do
    response = fake_response(%{id: 1, name: "XYZ", address: "123 Street", company_id: 1}, 200)
    params = Poison.encode!(%{address: "123 Street", company_id: 1, name: "XYZ"})
    mock :post_data, response, params, fn ->
      assert {:ok, %Brighterx.Resources.Facility{id: 1, name: "XYZ", address: "123 Street", company_id: 1}} === Api.create_facility(1, %{name: "XYZ", address: "123 Street"})
    end
  end

  test "get_device works correctly" do
    response = fake_response(%{id: 1, name: "XYZ"}, 200)
    mock :get, response, fn ->
      assert {:ok, %Brighterx.Resources.Device{id: 1, name: "XYZ"}} === Api.get_device(1)
      assert {:ok, %Brighterx.Resources.Device{id: 1, name: "XYZ"}} === Api.get_device("Sam")
    end
  end

  test "process_url/1 creates correct url path" do
    assert Api.process_url("/awesome") === "#{Api.url(Mix.env)}/awesome"
    System.put_env("BRIGHTERX_ENV", "prod")
    assert Api.process_url("/awesome") === "#{Api.url(:prod)}/awesome"
  end

  test "url returns appropriate url" do
    assert Api.url(:test) === Api.url(:stage)
    assert Api.url(:unknownenv) === Api.url(:stage)
    assert Api.url === Api.url(:stage)
  end

  test "url returns appropriate url based on environment" do
    assert Api.url(:dev) =~ "localhost:4001"
    assert Api.url(:prod) === "https://api.brighterlink.io"
  end

  test "url returns appropriate url based on System environment" do
    System.put_env("BRIGHTERX_ENV", "dev")
    assert Api.url === Api.url(:dev)
    System.put_env("BRIGHTERX_ENV", "stage")
    assert Api.url === Api.url(:stage)
    System.put_env("BRIGHTERX_ENV", "prod")
    assert Api.url === Api.url(:prod)
  end

  test "request_header creates correct request header" do
    req_header = Api.request_header_content_type(%{token: "sometoken"})
    assert req_header === [{"Content-Type", "application/json"}, {"User-agent", "Brighterx"}, {"Authorization", "Bearer sometoken"}]
  end
end
