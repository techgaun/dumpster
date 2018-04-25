defmodule HubGateway.Helpers.ZWave do
  import Bitwise
  require Logger
  alias HubGateway.ZWave.Devices.{BinarySwitch, DoorLock, Switch, Thermostat}

  @devices [
    BinarySwitch,
    DoorLock,
    Switch,
    Thermostat
  ]

  @command_classes [
    {"door_lock", 0x62},
    {"switch", 0x25},
    {"switch", 0x26},
    {"switch", 0x27},
    {"thermostat", 0x40}
  ]

  @command_set 0x01
  @command_get 0x02

  @device_types %{
    "dimmer" => "level",
    "level" => "level",
    "switch" => "level"
  }

  defp find_core_from_command_class(types) when is_list(types) do
    types
    |> Enum.find_value(fn type ->
      @command_classes
      |> Enum.find(fn {_key, value} ->
        type == value
      end)
      |> case do
        nil -> false
        cc -> cc
      end
    end)
  end
  defp find_core_from_command_class(type), do: find_core_from_command_class([type])

  defp infer_device_type(status) do
    status_keys = status
                  |> Map.keys()
                  |> Enum.map(&String.downcase/1)
    {device, _} =
      @devices
      |> Stream.map(fn device ->
        {device, status_attrs_matches(status_keys, device.get_all_attributes())}
      end)
      |> Stream.reject(fn {_, {matches, _}} -> matches < 1 end)
      |> Enum.max_by(
        fn {_, {matches, _}} -> matches end,
        fn -> {:error, nil} end
      )
    device
  end

  defp status_attrs_matches(status_keys, attrs) do
    attrs = attrs
            |> Enum.into(%{})
            |> Map.values()
            |> Enum.map(&String.downcase/1)

    status_keys
    |> Enum.reduce({0, 0}, fn status, {match, non_match} ->
      if status in attrs do
        {match + 1, non_match}
      else
        {match, non_match + 1}
      end
    end)
  end

  def translate_create(hub_ident, %{"n" => 1, "m" => model}) do
    {:ok,
      %{
        type: "gateway",
        identifier: hub_ident,
        model: model
      }
    }
  end
  def translate_create(hub_ident, %{"n" => node_id, "m" => model, "t" => types}) do
    case find_core_from_command_class(types) do
      nil -> {:error, "No device type found in command class list #{inspect types}"}
      {type, cc} ->
        {:ok,
          %{
            type: type,
            identifier: "#{hub_ident}_#{node_id}",
            model: model,
            udf: %{
              primary_cc: cc
            }
          }
        }
    end
  end

  def translate_status(hub_ident, %{"n" => node_id, "ts" => device_ts} = status) do
    device_ident = "#{hub_ident}_#{node_id}"
    status = Map.drop(status, ~w(n ts))
    case infer_device_type(status) do
      :error ->
        Logger.warn("Device type could not be inferred from #{inspect status}")
        []
      device_type ->
        result_status =
          status
          |> Enum.reduce([], fn {key, value}, acc ->
            key = String.downcase(key)

            kvp =
              key
              |> device_type.get_attribute
              |> case do
                {:ok, attribute} ->
                  key
                  |> device_type.get_value_for_attribute(value)
                  |> case do
                    {:ok, value} -> {device_type, {attribute, value}}
                    {:error, msg} -> {:error, msg}
                  end
                {:error, msg} -> {:error, msg}
              end
            [kvp | acc]
          end)
          |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

        {errors, updates} = Map.pop(result_status, :error, [])

        if Enum.count(errors) > 0 do
          Logger.warn("Status for #{inspect device_ident} contained errors: #{inspect List.flatten(errors)}")
        end

        Enum.map(updates, fn {device_type, values} ->
          values
          |> List.flatten
          |> Enum.into(%{})
          |> device_type.final_attribute_map
          |> Map.put("device_timestamp", norm_ts(device_ts))
          |> Map.put("identifier", device_ident)
          |> Map.put("device_type", device_type.get_core_type())
          |> Map.put("status", "online") # TODO: Handle this better way
        end)
    end
  end

  def translate_command(%{"type" => "gateway", "command" => %{"action" => action} = cmd}) do
    {:ok, %{c: action, t: Map.get(cmd, "type", "z")}}
  end
  def translate_command(%{"type" => device_type, "command" => %{"action" => _action} = command, "primary_cc" => primary_cc}) do
    @devices
    |> Enum.find(fn type -> type.get_core_type(primary_cc) == device_type end)
    |> case do
      nil -> {:error, "Invalid device type '#{device_type}'"}
      type -> type.build_command(command)
    end
  end

  def translate_command(cmd) do
    Logger.error("Invalid command received #{inspect cmd}")
    {:error, "Invalid command received"}
  end

  def translate_remove(ident, %{"n" => nid}), do: {:ok, %{identifier: "#{ident}_#{nid}"}}
  def translate_remove(_, payload), do: {:error, "Invalid data received for remove: '#{inspect payload}'"}

  def compose_translation(device_type, %{"action" => action,
                                          "attributes" => attributes,
                                          "device_address" => <<_mac :: size(136)>> <> "_" <> _node_id} = _command) do
    c =
      case action do
        "read" -> "rd"
        "write" -> "wr"
      end

    vt = @device_types[device_type]

    Enum.map(attributes, fn {_key, value} ->
      %{c: c, vt: vt, v: value, }
    end)
  end

  def get_command_class_from_key(key) do
    case Enum.find(@command_classes, nil, fn {k, _v} -> k == key end) do
      {^key, command_class} -> command_class
      nil -> nil
    end
  end

  def get_key_from_command_class(command_class) do
    case Enum.find(@command_classes, nil, fn {_k, v} -> v == command_class end) do
      {key, ^command_class} -> key
      nil -> nil
    end
  end

  @doc """
  Accepts a standard formatted command for a device from
  our back-end and translates it to a smaller message to
  be sent to the hub.

  Any invalid commands will be filtered out and excluded
  from the returned result. It is possible the original
  command will result in multiple ZWave commands, so the 
  returned map is detailed below.

  %{c: <list of resulting commands>, m: <msg id>, n: <node id derived from identifier>}
  """
  @spec raw_command(Map.t) :: {atom, Map.t}
  def raw_command(%{"type" => device_type, "command" => %{"action" => action} = command}) do
    device_type
    |> case do
      "door_lock" -> get_door_lock_command(action, command)
      "switch" -> get_switch_command(action, command)
      "thermostat" -> get_thermostat_command(action, command)
      _ -> []
    end
    |> case do
      {:ok, commands} ->
        commands = commands |> Enum.reject(fn c -> c == :invalid end)
        %{"device_address" => <<_mac :: size(136)>> <> "_" <> node_id} = command
        {:ok, %{c: Enum.map(commands, fn c -> complete_msg(node_id, c) end)}}
      {:error, msg} -> {:error, %{message: msg}}
    end
  end

  defp get_door_lock_command(action, msg_cmd) do
    command = [get_command_class_from_key("door_lock")]

    action
    |> case do
      "write" -> [command, @command_set]
      "read" -> [command, @command_get]
      _ -> :invalid
    end
    |> case do
      :invalid -> {:error, "Invalid action \"#{action}\""}
      [_, @command_get] = command -> {:ok, [[0x02, command, 0x25, 0x15]]}
      [_, @command_set] = command ->
        case msg_cmd do
          %{"attributes" => attributes} ->
            commands =
              Enum.map(attributes, fn {key, value} ->
                case key do
                  "state" -> [0x03, command, (if value == "unlocked", do: 0x00, else: 0xff), 0x05, 0x03]
                  _ -> :invalid
                end
              end)
            {:ok, commands}
          _ ->
            {:ok, [:invalid]}
        end
    end
  end

  defp get_switch_command(action, msg_cmd) do
    command = [get_command_class_from_key("switch")]

    action
    |> case do
      "write" -> [command, @command_set]
      "read" -> [command, @command_get]
      _ -> :invalid
    end
    |> case do
      :invalid -> {:error, "Invalid action \"#{action}\""}
      [_, @command_get] = command -> {:ok, [[0x02, command, 0x25, 0x15]]}
      [_, @command_set] = command ->
        case msg_cmd do
          %{"attributes" => attributes} ->
            commands =
              Enum.map(attributes, fn {key, value} ->
                case key do
                  "state" -> [0x03, command, (if value == "off", do: 0x00, else: 99), 0x05, 0x03]
                  _ -> :invalid
                end
              end)
            {:ok, commands}
          _ ->
            {:ok, [:invalid]}
        end
    end
  end

  defp get_thermostat_command(_action, %{"attributes" => _attributes}) do
    {:error, "Not implemented"}
  end

  defp complete_msg(node_id, msg) when is_binary(node_id) do
    case Integer.parse(node_id) do
      {id, ""} -> complete_msg(id, msg)
      :error -> :invalid
    end
  end
  defp complete_msg(node_id, msg) do
    msg = [0x00, 0x13, node_id, msg]
    msg = [get_nested_size(msg) + 1, msg]
    msg = [0x01, msg, calc_checksum(List.flatten(msg))]
    List.flatten(msg)
  end

  def get_nested_size([a | rest]) do
    get_nested_size(a) + get_nested_size(rest)
  end
  def get_nested_size([]), do: 0
  def get_nested_size(_a), do: 1

  def calc_checksum(list, total \\ 0xff)
  def calc_checksum([], total), do: total
  def calc_checksum([a], total) when is_list(a), do: calc_checksum(a, total)
  def calc_checksum([a | rest], total) do
    calc_checksum(rest, total ^^^ a)
  end

  defp norm_ts(ts) when is_integer(ts), do: ts |> DateTime.from_unix! |> DateTime.to_iso8601
  defp norm_ts(ts), do: ts
end
