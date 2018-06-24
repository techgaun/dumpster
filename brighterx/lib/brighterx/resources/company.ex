defmodule Brighterx.Resources.Company do
  @moduledoc """
  A company resource
  """

  @derive [Poison.Encoder]
  defstruct id: nil,
            name: nil,
            email: nil,
            phone: nil,
            cname: nil,
            billing_address: nil,
            shipping_address: nil,
            enabled: nil,
            udf: nil,
            schedule_id: nil,
            facilities: []
end
