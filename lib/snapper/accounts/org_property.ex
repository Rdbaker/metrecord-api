defmodule Metrecord.Accounts.OrgProperty do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @timestamps_opts [type: :utc_datetime]

  schema "org_properties" do
    field :name, :string, primary_key: true
    field :value, :string
    field :namespace, :string
    field :type, :string
    belongs_to :org, Metrecord.Accounts.Org, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(property, attrs) do
    property
    |> cast(attrs, [:name, :value, :type, :namespace])
    |> validate_required([:name, :value, :type, :namespace])
  end
end
