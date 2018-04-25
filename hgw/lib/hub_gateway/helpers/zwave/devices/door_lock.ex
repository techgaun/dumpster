defmodule HubGateway.ZWave.Devices.DoorLock do
  use HubGateway.ZWave.Device,
    core_type: "door_lock",
    attributes: [
      {"state", "locked"},
      {"alarm_level", "alarm level"},
      {"event", "alarm type"},
      {"battery", "battery level"}
    ]

  def get_core_type(_), do: "door_lock"

  def get_value_type("user_code_" <> index), do: {:ok, "Code #{index}:"}

  def get_value_for_type("state" = attribute, value) do
    case value do
      "locked" -> {:ok, true}
      "lock" -> {:ok, true}
      "unlock" -> {:ok, false}
      "unlocked" -> {:ok, false}
      _ -> {:error, "Invalid value, '#{value}', for attribute '#{attribute}'"}
    end
  end
  def get_value_for_type("user_code_" <> _, nil), do: {:ok, <<1>> <> to_string(round(:rand.uniform() * 1000000))}
  def get_value_for_type("user_code_" <> _, -1), do: {:ok, <<0,0,0,0,0>>}
  def get_value_for_type("user_code_" <> _ = attribute, value) do
    case Integer.parse(to_string(value)) do
      {code, ""} -> {:ok, <<1>> <> to_string(code)}
      _ -> {:error, "Invalid value, '#{inspect value}', for attribute '#{attribute}'. Value must only contain numbers."}
    end
  end

  def get_attribute("code " <> number) do
    case String.reverse(number) do
      ":" <> code -> {:ok, "user_code_#{String.reverse(code)}"}
      _ -> {:error, "Invalid code: '#{number}'"}
    end
  end

  def get_value_for_attribute("locked", true), do: {:ok, "locked"}
  def get_value_for_attribute("locked", false), do: {:ok, "unlocked"}
  def get_value_for_attribute("locked", _), do: {:ok, "unknown"}

  def get_value_for_attribute("alarm level", value), do: {:ok, value}

  def get_value_for_attribute("alarm type", 21), do: {:ok, "manual_lock_secured"}
  def get_value_for_attribute("alarm type", 22), do: {:ok, "manual_lock_unsecured"}
  def get_value_for_attribute("alarm type", 18), do: {:ok, "pin_lock_secured"}
  def get_value_for_attribute("alarm type", 19), do: {:ok, "pin_lock_unsecured"}
  def get_value_for_attribute("alarm type", 33), do: {:ok, "del_user_code"}
  def get_value_for_attribute("alarm type", 112), do: {:ok, "new_user_code"}
  def get_value_for_attribute("alarm type", 113), do: {:ok, "new_user_code_dup"}
  def get_value_for_attribute("alarm type", 167), do: {:ok, "battery_low"}
  def get_value_for_attribute("alarm type", 168), do: {:ok, "battery_critical"}
  def get_value_for_attribute("alarm type", 169), do: {:ok, "battery_dead"}
  def get_value_for_attribute("battery level", battery) when is_number(battery) and battery >= 0, do: {:ok, battery}

  def get_value_for_attribute("code" <> rest, value) when is_bitstring(value) do
    case Integer.parse(value) do
      {value, _} -> {:ok, value}
      _ -> {:error, "An error occured when parsing the value, '#{inspect value}', for attribute 'code#{rest}'."}
    end
  end

  def final_attribute_map(%{"event" => "manual_" <> event, "alarm_level" => user_code} = values) when event in ~w(lock_secured lock_unsecured) do
    user_code =
      case user_code do
        1 -> "thumb-turn/key"
        2 -> "keypad"
        _ -> "unknown"
      end

    values
    |> Map.put("alarm_level", user_code)
    |> Map.put("event", "pin_" <> event)
    |> final_attribute_map
  end
  def final_attribute_map(%{"event" => "pin_" <> event, "alarm_level" => user_code} = values) when event in ~w(lock_secured lock_unsecured) do
    values
    |> Map.drop(["alarm_level"])
    |> Map.put("event", event)
    |> Map.put("source", (if is_integer(user_code), do: "user_code_#{user_code}", else: user_code))
    |> Map.put("state", (if event === "lock_secured", do: "locked", else: "unlocked"))
    |> final_attribute_map
  end
  def final_attribute_map(%{"event" => action, "alarm_level" => user_code} = values)
    when action in ["new_user_code", "new_user_code_dup", "del_user_code"] do
    values
    |> Map.drop(["alarm_level"])
    |> Map.put("user_code", user_code)
    |> final_attribute_map
  end
end
