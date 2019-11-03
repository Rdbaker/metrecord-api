defmodule Metrecord.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "events" do
    field :name, :string
    field :data, :map
    field :dedup_key, :string
    field :event_type, :string
    belongs_to :org, Metrecord.Accounts.Org
    belongs_to :end_user, Metrecord.Accounts.EndUser, type: :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :data, :dedup_key, :event_type])
    |> validate_required([:name, :data, :event_type])
  end
end
