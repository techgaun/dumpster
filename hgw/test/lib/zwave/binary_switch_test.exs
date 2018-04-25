defmodule HubGateway.ZWave.Devices.BinarySwitchTest do
  use ExUnit.Case
  alias HubGateway.ZWave.Devices.BinarySwitch

  test "handles invalid type as expected" do
    {:error, msg} = BinarySwitch.get_value_for_type("state", :invalid)
    assert msg =~ "Invalid value"
  end
end
