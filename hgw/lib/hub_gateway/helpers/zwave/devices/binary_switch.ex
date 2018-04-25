defmodule HubGateway.ZWave.Devices.BinarySwitch do
  use HubGateway.ZWave.Device,
    core_type: "switch",
    attributes: [
      {"state", "switch"}
    ],
    primary_cc: 0x25

  def get_core_type(0x25), do: "switch"
  def get_core_type(_), do: :error

  def get_value_for_type("state" = attribute, value) do
    case value do
      "on" -> {:ok, true}
      "off" -> {:ok, false}
      _ -> {:error, "Invalid value, '#{value}', for attribute '#{attribute}'"}
    end
  end

  def get_value_for_attribute("switch", true), do: {:ok, "on"}
  def get_value_for_attribute("switch", false), do: {:ok, "off"}
  def get_value_for_attribute("switch", _), do: {:ok, "unknown"}
end
