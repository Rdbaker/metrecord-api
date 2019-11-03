defmodule Metrecord.Events.Chart do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "charts" do
    field :name, :string
    field :config, :map
    field :meta, :map
    belongs_to :org, Metrecord.Accounts.Org

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :config, :meta])
    |> validate_required([:name, :config, :meta])
  end
end
