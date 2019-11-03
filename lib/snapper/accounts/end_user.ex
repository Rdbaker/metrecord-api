defmodule Metrecord.Accounts.EndUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  @timestamps_opts [type: :utc_datetime]

  schema "end_users" do
    belongs_to :org, Metrecord.Accounts.Org

    timestamps()
  end

  @doc false
  def changeset(end_user, attrs) do
    end_user
    |> cast(attrs, [:id])
    |> validate_required([:id])
  end
end
