defmodule HubGateway.Helpers.ZWaveTest do
  use ExUnit.Case
  alias HubGateway.Helpers.ZWave
  import ExUnit.CaptureLog

  @hub_ident "00:01:02:03:04:05"

  test "translate create payload" do
    assert {:error, msg} = ZWave.translate_create(@hub_ident, %{"n" => 2, "m" => "test", "t" => 0x01})
    assert msg =~ "list 1"

    {:ok, %{type: "gateway"}} = ZWave.translate_create(@hub_ident, %{"n" => 1, "m" => "Aeon"})

  end

  test "translate status payload" do
    status = %{
      "n" => 2,
      "ts" => System.system_time(:second),
      "Mode" => "Auto",
      "Unknown" => "Attribute"
    }

    [%{"device_type" => "thermostat", "system_mode" => "auto", "identifier" => "#{@hub_ident}_2"} = translated] = ZWave.translate_status(@hub_ident, status)
    assert translated["device_timestamp"] == (DateTime.from_unix!(status["ts"]) |> DateTime.to_iso8601)

    ts_str = DateTime.utc_now |> DateTime.to_iso8601
    status = %{status | "ts" => ts_str}
    [translated] = ZWave.translate_status(@hub_ident, status)
    assert translated["device_timestamp"] == ts_str
  end

  test "unknown device type does not work" do
    status = %{
      "n" => 2,
      "ts" => System.system_time(:second),
      "Unknown" => "Attribute"
    }

    assert capture_log(fn ->
      ZWave.translate_status(@hub_ident, status)
    end) =~ "Device type could not be inferred"
  end

  test "translate command payload" do
    cmd = %{
      "type" => "unknown",
      "command" => %{
        "device_address" => "#{@hub_ident}_2",
        "action" => "write",
        "attributes" => %{
          "system_mode" => "off"
        },
      },
      "primary_cc" => 0x40
    }

    {:error, _msg} = ZWave.translate_command(cmd)

    cmd = %{cmd | "type" => "thermostat"}
    {:ok, %{a: "wr", c: [%{v: "Off", vt: "mode"}], n: 2, t: "z"}} = ZWave.translate_command(cmd)

    bad_cmd = %{bad: :cmd}
    {:error, _msg} = ZWave.translate_command(bad_cmd)

    gateway_cmd = %{"type" => "gateway", "command" => %{"action" => "add"}}
    {:ok, %{c: "add", t: "z"}} = ZWave.translate_command(gateway_cmd)
  end

  test "composing translation works as expected" do
    cmd = %{
      "type" => "switch",
      "command" => %{
        "device_address" => "#{@hub_ident}_2",
        "action" => "write",
        "attributes" => %{
          "level" => 100
        }
      }
    }

    [%{c: "wr", v: 100, vt: "level"}] = ZWave.compose_translation(cmd["type"], cmd["command"])
  end

  test "getting command class from key and key from CC works fine" do
    assert ZWave.get_command_class_from_key("door_lock") == 0x62
    assert ZWave.get_key_from_command_class(0x62) == "door_lock"
  end

  test "raw command for zwave" do
    cmd = %{
      "type" => "switch",
      "command" => %{
        "device_address" => "#{@hub_ident}_2",
        "action" => "write",
        "attributes" => %{
          "state" => "on"
        }
      }
    }

    {:ok, %{c: [raw_cmd]}} = ZWave.raw_command(cmd)
    assert Enum.count(raw_cmd) == 12
    assert Enum.at(raw_cmd, 0) == 1
    assert Enum.at(raw_cmd, 1) == Enum.count(raw_cmd) - 2

    invalid_cmd = put_in(cmd["command"]["action"], "invalid")
    {:error, %{message: "Invalid action \"invalid\""}} = ZWave.raw_command(invalid_cmd)

    cmd = %{cmd | "type" => "door_lock"}
          |> put_in(~w(command attributes state), "locked")

    {:ok, %{c: [raw_cmd]}} = ZWave.raw_command(cmd)
    assert Enum.count(raw_cmd) == 12
    assert Enum.at(raw_cmd, 0) == 1
    assert Enum.at(raw_cmd, 1) == Enum.count(raw_cmd) - 2

    invalid_cmd = put_in(cmd["command"]["action"], "invalid")
    {:error, %{message: "Invalid action \"invalid\""}} = ZWave.raw_command(invalid_cmd)

    cmd = %{cmd | "type" => "thermostat"}

    assert {:error, %{message: "Not implemented"}} == ZWave.raw_command(cmd)
  end

  test "calc_checksum for list" do
    assert ZWave.calc_checksum([[1, 2, 3]]) == 255
    assert ZWave.calc_checksum([[1, 2, 3, 4, 5, 6]]) == 248
  end
end
