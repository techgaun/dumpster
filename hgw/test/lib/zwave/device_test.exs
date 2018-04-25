defmodule HubGateway.ZWave.DeviceTest do
  use ExUnit.Case

  defmodule TstModule do
    use HubGateway.ZWave.Device,
      core_type: "tst",
      attributes: [
        {"hello", "world"}
      ]
  end

  test "module using device has appropriate functions" do
    assert TstModule.get_core_type() == "tst"
    assert TstModule.get_value_type("hello") == {:ok, "world"}
    assert {:error, _} = TstModule.get_value_type("invalid")
  end
end
