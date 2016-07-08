defmodule UtilityAnalyzer.UtilityData do
  use Ecto.Schema
  alias UtilityAnalyzer.Repo
  import Ecto.Changeset

  schema "utility_data" do
    field :account_num, :string, size: 48
    field :customer_name, :string
    field :service_address, :string
    field :zipcode, :string, size: 10
    field :statement_date, :string
    field :amount, :string
    field :prev_amount, :string
    field :last_payment_date, :string
    field :due_date, :string
    field :delinquent_date, :string
    field :delinquent_amount, :string
    field :meter_readings, :map
    field :yearly_usage, :map, default: nil
    field :usage_summary, :map
    field :usage_detail, :map
    field :tariff, :string, size: 150
    field :secondary_tariff, :string, size: 150

    timestamps(updated_at: false)
  end

  @required_fields ~w(account_num customer_name)
  @optional_fields ~w(service_address zipcode statement_date amount prev_amount last_payment_date due_date delinquent_date delinquent_amount meter_readings yearly_usage usage_summary usage_detail tariff secondary_tariff)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
