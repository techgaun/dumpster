defmodule UtilityAnalyzer.Repo.Migrations.AddUtilityDataTable do
  use Ecto.Migration

  def change do
    create table(:utility_data) do
      add :account_num, :string, size: 48
      add :customer_name, :string
      add :service_address, :string
      add :zipcode, :string, size: 10
      add :statement_date, :string
      add :amount, :string
      add :prev_amount, :string
      add :last_payment_date, :string
      add :due_date, :string
      add :delinquent_date, :string
      add :delinquent_amount, :string
      add :meter_readings, :map
      add :yearly_usage, :map, default: nil
      add :usage_summary, :map
      add :usage_detail, :map
      add :tariff, :string, size: 150
      add :secondary_tariff, :string, size: 150
      add :inserted_at, :datetime
    end
  end
end
