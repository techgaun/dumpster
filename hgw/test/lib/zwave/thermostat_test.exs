defmodule HubGateway.ZWave.Devices.ThermostatTest do
  use ExUnit.Case
  alias HubGateway.ZWave.Devices.Thermostat

  test "thermostat devices are handled as expected" do
    assert Thermostat.get_core_type == "thermostat"
    assert Thermostat.get_value_for_type("system_mode", "heat") == {:ok, "Heat"}
    assert Thermostat.get_value_for_type("occ_heat_sp", 70) == {:ok, 70}
    assert Thermostat.get_value_for_type("fan_mode", "auto_low") == {:ok, "Auto Low"}
    {:error, msg} = Thermostat.get_value_for_type("fan_mode", "some_invalid")
    assert msg =~ "Invalid value"
    assert msg =~ "some_invalid"
    assert msg =~ "fan_mode"
  end
end
