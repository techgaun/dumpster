defmodule HubGateway.ZWave.Device do

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @__core_type__ opts[:core_type]
      @before_compile HubGateway.ZWave.Device

      opts[:attributes]
      |> Enum.each(fn {core, hub} ->
        def get_value_type(unquote(core)), do: {:ok, unquote(hub)}
        def get_attribute(unquote(hub)), do: {:ok, unquote(core)}
      end)

      def get_all_attributes, do: unquote(opts[:attributes])

      def build_command(%{"device_address" => device_address, "action" => action, "attributes" => attributes} = command) do
        device_address
        |> get_node_id
        |> case do
          {:error, msg} -> {:error, msg}
          {:ok, node_id} ->
            a = if action == "write", do: "wr", else: "rd"

            commands =
              a
              |> case do
                "rd" ->
                  Enum.map(attributes, fn att ->
                    att
                    |> get_value_type
                    |> case do
                      {:ok, vt} -> [{:vt, vt}]
                      {:error, msg} -> {:error, msg}
                    end
                  end)
                "wr" ->
                  Enum.map(attributes, fn {att, val} ->
                    att
                    |> get_value_type
                    |> case do
                      {:ok, vt} ->
                        att
                        |> get_value_for_type(val)
                        |> case do
                          {:ok, v} -> [{:vt, vt}, {:v, v}]
                          {:error, msg} -> {:error, msg}
                        end
                      {:error, msg} -> {:error, msg}
                    end
                  end)
                _ -> {:error, "Invalid action in message: #{action}"}
              end
              |> case do
                {:error, msg} -> {:error, msg}
                commands ->
                  commands
                  |> Enum.filter(fn c ->
                    case c do
                      {:error, _} -> true
                      _ -> false
                    end
                  end)
                  |> case do
                    [] ->
                      commands =
                        commands |> Enum.map(fn c -> c |> List.flatten |> Enum.into(%{}) end)
                      {:ok, %{t: "z", n: node_id, a: a, c: commands}}
                    errors ->
                      {:error,
                        errors |> Enum.map_join("\n", fn {:error, msg} -> msg end)
                      }
                  end
              end
        end
      end

      defp get_node_id(device_address) do
        case device_address do
          <<_mac :: size(136)>> <> "_" <> node_id ->
            case Integer.parse(node_id) do
              {nid, ""} -> {:ok, nid}
              _ -> {:error, "Invalid node ID"}
            end
          _ -> {:error, "Invalid zwave device address"}
        end
      end
    end
  end

  defmacro __before_compile__(env) do
    core_type = Module.get_attribute(env.module, :__core_type__)
    quote do
      def get_core_type, do: unquote(core_type)
      def get_value_type(attribute), do: {:error, "Invalid attribute '#{attribute}'"}
      def get_value_for_type(attribute, value), do: {:error, "Invalid value, '#{value}', for attribute '#{attribute}'"}
      def get_attribute(vt), do: {:error, "Invalid value type: '#{vt}"}
      def get_value_for_attribute(vt, value), do: {:error, "Unknown value, '#{value}', for value type '#{vt}'"}

      def get_value_type!(attribute) do
        case get_value_type(attribute) do
          {:ok, vt} -> vt
          {:error, msg} -> raise(msg)
        end
      end
      def get_value_for_type!(attribute, value) do
        case get_value_for_type(attribute, value) do
          {:ok, value} -> value
          {:error, msg} -> raise(msg)
        end
      end
      def get_attribute!(vt) do
        case get_attribute(vt) do
          {:ok, att} -> att
          {:error, msg} -> raise(msg)
        end
      end
      def get_value_for_attribute!(vt, value) do
        case get_value_for_attribute(vt, value) do
          {:ok, value} -> value
          {:error, msg} -> raise(msg)
        end
      end
      def final_attribute_map(values), do: values

      def norm_zwave_str(str) do
        str
        |> String.split("_")
        |> Stream.map(&String.capitalize/1)
        |> Enum.join(" ")
      end

      def denorm_zwave_str(str) do
        str
        |> String.split(" ")
        |> Stream.map(&String.downcase/1)
        |> Enum.join("_")
      end
    end
  end
end
