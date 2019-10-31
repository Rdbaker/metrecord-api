defmodule Snapper.Repo.Migrations.CreateDashboardsTable do
  use Ecto.Migration

  def change do
    create table(:dashboards, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :org_id, references(:orgs)
      add :config, :map
      add :meta, :map

      timestamps(type: :timestamptz)
    end

    create index(:dashboards, [:org_id])

    create table(:charts_dashboards, primary_key: false) do
      add :chart_id, references(:charts, type: :uuid), primary_key: true
      add :dashboard_id, references(:dashboards, type: :uuid), primary_key: true
      add :config, :map
    end

    create index(:charts_dashboards, [:chart_id, :dashboard_id])
  end
end
