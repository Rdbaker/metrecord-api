defmodule Metrecord.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :email, :string
      add :password_hash, :string
      add :org_id, references(:orgs)

      timestamps(type: :timestamptz)
    end

    create unique_index(:users, [:email])
  end
end
