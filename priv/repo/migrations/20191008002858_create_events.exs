defmodule Snapper.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :org_id, references(:orgs)
      add :end_user_id, references(:end_users, type: :string)
      add :event_type, :string
      add :name, :string
      add :dedup_key, :string
      add :data, :map

      timestamps(type: :timestamptz)
    end

    create index(:events, [:org_id])
    create index(:events, [:end_user_id])
    create index(:events, [:event_type])
    create index(:events, [:inserted_at])
    create index(:events, [:name])
    create unique_index(:events, [:dedup_key])
  end
end
