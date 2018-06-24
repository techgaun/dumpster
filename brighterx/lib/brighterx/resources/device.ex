defmodule Brighterx.Resources.Device do
  @moduledoc """
  A Device resource
  """

  @derive [Poison.Encoder]
  defstruct id: nil,
            name: nil,
            location: nil,
            type: nil,
            make: nil,
            model: nil,
            identifier: nil,
            udf: nil,
            last_state: nil,
            parent_id: nil,
            facility_id: nil,
            enabled: nil
end
