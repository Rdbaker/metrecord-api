defmodule Snapper.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Snapper.Repo

  alias Snapper.Accounts.User
  alias Snapper.Accounts.Org

  def authenticate_by_email_password(email, password) do
    user = Repo.get_by(User, email: email)
    case Bcrypt.check_pass(user, password) do
      {:ok, _} -> {:ok, user}
      {:error, _} -> {:error, :unauthorized}
    end
  end

  def generate_random_string(len) do
    :crypto.strong_rand_bytes(len) |> Base.url_encode64 |> binary_part(0, len)
  end


  @doc """
  Returns the list of users.
  ## Examples
      iex> list_users()
      [%User{}, ...]
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.
  Raises `Ecto.NoResultsError` if the User does not exist.
  ## Examples
      iex> get_user!(123)
      %User{}
      iex> get_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  ## Examples
      iex> create_user(%{field: value})
      {:ok, %User{}}
      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_user(attrs \\ %{}) do
    case create_org() do
      {:ok, org} ->
        %User{}
        |> User.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:org, org)
        |> Repo.insert()
    end
  end

  @doc """
  Updates a user.
  ## Examples
      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}
      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  ## Examples
      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}
  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  # @doc """
  # Returns the list of end_users.
  # ## Examples
  #     iex> list_end_users()
  #     [%EndUser{}, ...]
  # """
  # def list_end_users do
  #   Repo.all(EndUser)
  # end

  # def bulk_get_end_users(ids) do
  #   Repo.all(from(e in EndUser, where: e.id in ^ids))
  # end

  # @doc """
  # Gets a single end_user.
  # Raises `Ecto.NoResultsError` if the End user does not exist.
  # ## Examples
  #     iex> get_end_user!(123)
  #     %EndUser{}
  #     iex> get_end_user!(456)
  #     ** (Ecto.NoResultsError)
  # """
  # def get_end_user!(id), do: Repo.get!(EndUser, id)

  # @doc """
  # Creates a end_user.
  # ## Examples
  #     iex> create_end_user(%{field: value})
  #     {:ok, %EndUser{}}
  #     iex> create_end_user(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  # """
  # def create_end_user(attrs \\ %{}) do
  #   %EndUser{}
  #   |> EndUser.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Updates a end_user.
  # ## Examples
  #     iex> update_end_user(end_user, %{field: new_value})
  #     {:ok, %EndUser{}}
  #     iex> update_end_user(end_user, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  # """
  # def update_end_user(%EndUser{} = end_user, attrs) do
  #   end_user
  #   |> EndUser.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a EndUser.
  # ## Examples
  #     iex> delete_end_user(end_user)
  #     {:ok, %EndUser{}}
  #     iex> delete_end_user(end_user)
  #     {:error, %Ecto.Changeset{}}
  # """
  # def delete_end_user(%EndUser{} = end_user) do
  #   Repo.delete(end_user)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking end_user changes.
  # ## Examples
  #     iex> change_end_user(end_user)
  #     %Ecto.Changeset{source: %EndUser{}}
  # """
  # def change_end_user(%EndUser{} = end_user) do
  #   EndUser.changeset(end_user, %{})
  # end


  @doc """
  Gets a single org.
  Raises `Ecto.NoResultsError` if the Org does not exist.
  ## Examples
      iex> get_org!(123)
      %Org{}
      iex> get_org!(456)
      ** (Ecto.NoResultsError)
  """
  def get_org!(id), do: Repo.get!(Org, id)

  def get_org_by_client_id(client_id) do
    case Repo.get_by(Org, client_id: client_id) do
      nil ->
        {:error, :not_found}
      org ->
        {:ok, org}
    end
  end

  @doc """
  Creates a org.
  ## Examples
      iex> create_org(%{field: value})
      {:ok, %Org{}}
      iex> create_org(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_org(attrs \\ %{}) do
    %Org{
      client_id: generate_random_string(12),
      client_secret: generate_random_string(46),
    }
    |> Org.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking org changes.
  ## Examples
      iex> change_org(org)
      %Ecto.Changeset{source: %Org{}}
  """
  def change_org(%Org{} = org) do
    Org.changeset(org, %{})
  end

  # def get_properties_for_org(org_id) do
  #   Repo.all(from(o in OrgProperty, where: o.org_id == ^org_id))
  # end

  # def upsert_org_property(org_id, name, value, type, namespace) do
  #   prop = Repo.get_by(OrgProperty, org_id: org_id, name: name, namespace: namespace)
  #   case prop == nil do
  #     false ->
  #       prop
  #       |> OrgProperty.changeset(%{ value: value, type: type })
  #       |> Repo.update()
  #     true ->
  #       %OrgProperty{
  #         name: name,
  #         value: value,
  #         type: type,
  #         namespace: namespace,
  #         org_id: org_id
  #       }
  #       |> Repo.insert()
  #   end
  # end

  # def upsert_org_gate(org_id, name, enabled) do
  #   upsert_org_property(org_id, name, enabled, "boolean", "GATES")
  # end

  # def upsert_org_setting(org_id, name, value, type) do
  #   upsert_org_property(org_id, name, value, type, "SETTINGS")
  # end
end
