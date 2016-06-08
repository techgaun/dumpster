defmodule SalesforceData.Repo.Migrations.CreateThreeMTable do
  use Ecto.Migration

  def change do
    create table(:three_ms) do
      add :sfid, :string, size: 100
      add :name, :string, size: 255
      add :sfdata, :map
      add :inserted_at, :datetime
    end
  end
end
