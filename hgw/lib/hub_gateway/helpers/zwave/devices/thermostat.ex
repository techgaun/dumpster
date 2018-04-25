defmodule HubGateway.ZWave.Devices.Thermostat do
  @moduledoc """
  This module represents the capability of zwave thermostat device.
  """

  use HubGateway.ZWave.Device,
    core_type: "thermostat",
    attributes: [
      {"unit_type", "temperature unit"},
      {"system_mode", "mode"},
      {"running_mode", "operating state"},
      {"current_temp", "temperature"},
      {"occ_heat_sp", "heating 1"},
      {"occ_cool_sp", "cooling 1"},
      {"fan_mode", "fan mode"},
      {"fan_state", "fan state"},
      {"battery", "battery level"},
    ]

  @allowed_fan_mode [
    "Auto Low",
    "On Low",
    "Auto High",
    "On High",
    "Circulate",
  ]

  @allowed_fan_state [
    "Idle",
    "Running",
    "Running High",
  ]

  def get_core_type(_), do: "thermostat"
  def get_value_for_type("system_mode", value) when value in ~w(auto off heat cool), do: {:ok, String.capitalize(value)}

  def get_value_for_type(setpoint, value) when setpoint in ~w(occ_heat_sp occ_cool_sp)
    and is_number(value), do: {:ok, value}

  def get_value_for_type("fan_mode" = attr, value) do
    norm_value = norm_zwave_str(value)

    if norm_value in @allowed_fan_mode do
      {:ok, norm_value}
    else
      {:error, "Invalid value, '#{value}', for attribute '#{attr}'"}
    end
  end

  def get_value_for_attribute("temperature unit", "Celsius"), do: {:ok, "c"}
  def get_value_for_attribute("temperature unit", _), do: {:ok, "f"}

  def get_value_for_attribute("mode", "Aux Heat"), do: {:ok, "heat"}
  def get_value_for_attribute("mode", mode) when mode in ~w(Auto Off Heat Cool), do: {:ok, String.downcase(mode)}

  def get_value_for_attribute("operating state", "Idle"), do: {:ok, "idle"}
  def get_value_for_attribute("operating state", "Fan Only"), do: {:ok, "fan_only"}
  def get_value_for_attribute("operating state", heat_state) when heat_state in ["Heating", "Pending Heat"], do: {:ok, "heat"}
  def get_value_for_attribute("operating state", cool_state) when cool_state in ["Cooling", "Pending Cool"], do: {:ok, "cool"}

  def get_value_for_attribute(temps, temp)
    when temps in ["temperature", "heating 1", "cooling 1"] and
    is_number(temp) and temp > 0, do: {:ok, temp}

  def get_value_for_attribute("fan mode", value) when value in @allowed_fan_mode, do: {:ok, denorm_zwave_str(value)}

  def get_value_for_attribute("fan state", value) when value in @allowed_fan_state, do: {:ok, denorm_zwave_str(value)}

  def get_value_for_attribute("battery level", battery) when is_number(battery) and battery >= 0, do: {:ok, battery}
end
