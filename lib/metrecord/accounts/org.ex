defmodule Metrecord.Accounts.Org do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  schema "orgs" do
    field :client_id, :string
    field :client_secret, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(org, attrs) do
    org
    |> cast(attrs, [:name])
    |> validate_required([])
  end
end
