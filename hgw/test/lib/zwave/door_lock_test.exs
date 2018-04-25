defmodule HubGateway.ZWave.Devices.DoorLockTest do
  use ExUnit.Case
  alias HubGateway.ZWave.Devices.DoorLock

  test "door locks are handled as expected" do
    assert DoorLock.get_core_type == "door_lock"

    assert DoorLock.get_value_type("user_code_1") == {:ok, "Code 1:"}
    assert DoorLock.get_value_for_type("state", "locked") == {:ok, true}
    {:error, msg} = DoorLock.get_value_for_type("state", "invalid")
    assert msg =~ "Invalid value, 'invalid'"

    {:ok, <<1>> <> lock_code} = DoorLock.get_value_for_type("user_code_1", nil)
    lock_code = String.to_integer(lock_code)
    assert lock_code < 1000000
    {:ok, <<1>> <> "123456"} = DoorLock.get_value_for_type("user_code_1", "123456")
    {:error, msg} = DoorLock.get_value_for_type("user_code_1", "not_a_lock_code")
    assert msg =~ "Invalid value"

    assert DoorLock.get_value_for_type("user_code_1", -1) == {:ok, <<0,0,0,0,0>>}

    assert DoorLock.get_attribute("code 1:") == {:ok, "user_code_1"}
    assert DoorLock.get_attribute("code invalid") == {:error, "Invalid code: 'invalid'"}

    assert DoorLock.get_value_for_attribute("code 1:", "123456") == {:ok, 123456}
    {:error, msg} = DoorLock.get_value_for_attribute("code 1:", "bad_code")
    assert msg =~ "error occured"

    attr_map = %{
      "event" => "manual_lock_secured",
      "alarm_level" => 2,
    }
    expected = %{
      "event" => "lock_secured",
      "source" => "keypad",
      "state" => "locked"
    }
    assert expected == DoorLock.final_attribute_map(attr_map)

    new_code_attr = %{
      "event" => "new_user_code",
      "alarm_level" => 2
    }

    new_code_attr_dup = %{
      "event" => "new_user_code_dup",
      "alarm_level" => 2
    }

    new_code_attr_del = %{
      "event" => "del_user_code",
      "alarm_level" => 2
    }

    assert %{"event" => "new_user_code", "user_code" => 2} == DoorLock.final_attribute_map(new_code_attr)
    assert %{"event" => "new_user_code_dup", "user_code" => 2} == DoorLock.final_attribute_map(new_code_attr_dup)
    assert %{"event" => "del_user_code", "user_code" => 2} == DoorLock.final_attribute_map(new_code_attr_del)
  end
end
