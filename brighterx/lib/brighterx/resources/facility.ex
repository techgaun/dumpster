defmodule Brighterx.Resources.Facility do
  @moduledoc """
  A facility resource
  """

  @derive [Poison.Encoder]
  defstruct id: nil,
            company_id: nil,
            name: nil,
            address: nil,
            udf: nil,
            schedule: nil,
            devices: [],
            enabled: nil
end
