defmodule UtilityAnalyzer.UtilityData do
  use Ecto.Schema

  schema "utility_data" do
    field :account_num, :string, size: 48
    field :customer_name, :string
    field :service_address, :string
    field :zipcode, :string, size: 10
    field :statement_date, Ecto.DateTime
    field :amount, :string
    field :prev_amount, :string
    field :last_payment_date, Ecto.DateTime
    field :due_date, Ecto.DateTime
    field :delinquent_date, Ecto.DateTime
    field :delinquent_amount, :string
    field :meter_readings, :map
    field :yearly_usage, :map, default: nil
    field :usage_summary, :map
    field :usage_detail, :map
    field :tariff, :string, size: 150
    field :secondary_tariff, :string, size: 150

    timestamps(updated_at: false)
  end
end
