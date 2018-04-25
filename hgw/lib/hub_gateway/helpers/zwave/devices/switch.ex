defmodule HubGateway.ZWave.Devices.Switch do
  use HubGateway.ZWave.Device,
  core_type: "switch",
  attributes: [
    {"state", "level"}
  ]

  def get_core_type(_), do: "switch"
  def get_value_for_type("state" = attribute, value) do
    case value do
      "on" -> {:ok, 99}
      "off" -> {:ok, 0}
      _ ->
        case Integer.parse(to_string(value)) do
          {value, ""} -> {:ok, value}
          _ -> {:error, "Invalid value, '#{value}', for attribute '#{attribute}'"}
        end
    end
  end

  def get_value_for_attribute("level", value) do
    case value do
      value when is_number(value) and value > 0 -> {:ok, "on"}
      0 -> {:ok, "off"}
      _ -> {:ok, "unknown"}
    end
  end
end
