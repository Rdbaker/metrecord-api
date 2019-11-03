defmodule Metrecord.Repo.Migrations.CreateOrgs do
  use Ecto.Migration

  def change do
    create table(:orgs) do

      add :client_id, :string
      add :client_secret, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:orgs, [:client_secret])
    create unique_index(:orgs, [:client_id])
  end
end
