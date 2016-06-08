defmodule SalesforceData.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :sfid, :string, size: 100
      add :name, :string, size: 100
      add :sfdata, :map
      add :inserted_at, :datetime
    end

    create table(:buildings) do
      add :sfid, :string, size: 100
      add :name, :string, size: 100
      add :sfdata, :map
      add :inserted_at, :datetime
    end

    create table(:products) do
      add :sfid, :string, size: 100
      add :name, :string, size: 100
      add :sfdata, :map
      add :inserted_at, :datetime
    end

    create table(:opportunities) do
      add :sfid, :string, size: 100
      add :name, :string, size: 100
      add :sfdata, :map
      add :inserted_at, :datetime
    end

    create table(:utility_accounts) do
      add :sfid, :string, size: 100
      add :name, :string, size: 100
      add :sfdata, :map
      add :inserted_at, :datetime
    end
  end
end
