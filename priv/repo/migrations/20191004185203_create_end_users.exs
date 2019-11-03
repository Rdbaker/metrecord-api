defmodule Metrecord.Repo.Migrations.CreateEndUsers do
  use Ecto.Migration

  def change do
    create table(:end_users, primary_key: false) do
      add :id, :string, primary_key: true
      add :org_id, references(:orgs)

      timestamps(type: :timestamptz)
    end
  end
end
