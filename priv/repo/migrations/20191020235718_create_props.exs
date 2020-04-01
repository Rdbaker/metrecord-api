defmodule Metrecord.Repo.Migrations.CreateOrgProps do
  use Ecto.Migration

  def change do
    create table(:org_properties, primary_key: false) do
      add :name, :string, primary_key: true
      add :org_id, references(:orgs), primary_key: true
      add :namespace, :string
      add :value, :text
      add :type, :string

      timestamps(type: :timestamptz)
    end

    create table(:user_properties, primary_key: false) do
      add :name, :string, primary_key: true
      add :user_id, references(:users, type: :uuid), primary_key: true
      add :namespace, :string
      add :value, :text
      add :type, :string

      timestamps(type: :timestamptz)
    end

    create table(:end_user_properties, primary_key: false) do
      add :name, :string, primary_key: true
      add :end_user_id, references(:end_users, type: :string), primary_key: true
      add :namespace, :string
      add :value, :text
      add :type, :string

      timestamps(type: :timestamptz)
    end
  end
end
