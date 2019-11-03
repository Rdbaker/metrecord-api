defmodule Metrecord.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :org, Metrecord.Accounts.Org

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> put_pass_hash
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
    %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
