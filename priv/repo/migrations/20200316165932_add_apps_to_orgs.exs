defmodule Metrecord.Repo.Migrations.AddAppsToOrgs do
  use Ecto.Migration

  def change do
    create table(:apps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :org_id, references(:orgs)
      add :name, :string
      add :slug, :string
      add :meta, :map
      add :client_id, :string
      add :client_secret, :string

      timestamps(type: :timestamptz)
    end

    create index(:apps, [:org_id])
    create unique_index(:apps, [:client_secret])
    create unique_index(:apps, [:client_id])
    create index(:apps, [:slug, :org_id])
  end
end
