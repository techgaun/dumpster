defmodule HubGateway.ZWave.Devices.SwitchTest do
  use ExUnit.Case
  alias HubGateway.ZWave.Devices.Switch

  test "switch handles switch device properly" do
    assert Switch.get_core_type == "switch"
    assert Switch.get_attribute("level") == {:ok, "state"}
    assert Switch.get_value_type("state") == {:ok, "level"}
    assert Switch.get_value_for_type("state", "on") == {:ok, 99}
    assert Switch.get_value_for_type("state", "off") == {:ok, 0}
    {:error, _} = Switch.get_value_for_type("state", "invalid")
    assert Switch.get_value_for_type("state", "50") == {:ok, 50}
    assert Switch.get_value_for_attribute("level", 99) == {:ok, "on"}
    assert Switch.get_value_for_attribute("level", 0) == {:ok, "off"}
    assert Switch.get_value_for_attribute("level", :invalid) == {:ok, "unknown"}
  end
end
