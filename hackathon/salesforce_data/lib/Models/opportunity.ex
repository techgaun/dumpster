defmodule SalesforceData.Opportunity do
  use Ecto.Schema

  schema "opportunities" do
    field :sfid, :string, size: 100
    field :name, :string, size: 255, default: ""
    field :sfdata, :map, default: %{}

    timestamps(updated_at: false)
  end
end