defmodule SalesforceData.Repo.Migrations.ChangeNameLength do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      modify :name, :string, size: 255
    end

    alter table(:buildings) do
      modify :name, :string, size: 255
    end

    alter table(:products) do
      modify :name, :string, size: 255
    end

    alter table(:opportunities) do
      modify :name, :string, size: 255
    end

    alter table(:utility_accounts) do
      modify :name, :string, size: 255
    end
  end
end
