defmodule Snapper.Repo.Migrations.CreateChartsTable do
  use Ecto.Migration

  def change do
    create table(:charts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :org_id, references(:orgs)
      add :config, :map
      add :meta, :map

      timestamps(type: :timestamptz)
    end

    create index(:charts, [:org_id])
  end
end
