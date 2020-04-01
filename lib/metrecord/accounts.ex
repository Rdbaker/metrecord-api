defmodule Metrecord.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Metrecord.Repo
  alias Stripe

  alias Metrecord.Accounts.EndUser
  alias Metrecord.Accounts.User
  alias Metrecord.Accounts.Org
  alias Metrecord.Accounts.OrgProperty
  alias Metrecord.Events.Subscription

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

  def get_user(id), do: Repo.get(User, id)

  def get_all_in_org(org_id) do
    Repo.all(from(u in User, where: u.org_id == ^org_id))
  end

  @doc """
  Creates a user.
  ## Examples
      iex> create_user(%{field: value})
      {:ok, %User{}}
      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_user(attrs \\ %{}, org_attrs \\ %{}) do
    changeset = %User{}
    |> User.changeset(attrs)
    case changeset.errors do
      [] ->
        ins = Repo.insert(changeset)
        case ins do
          {:ok, user} ->
            {_, org} = create_org(org_attrs)
            user
            |> Repo.preload(:org)
            |> Ecto.Changeset.change()
            |> Ecto.Changeset.put_assoc(:org, org)
            |> Repo.update()
          {:error, change} -> {:error, change}
        end
      _ -> {:error, changeset}
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

  def update_user_status(user, status) do
    user
    |> User.status_changeset(%{status: status})
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

  @doc """
  Finds or creates a end_user.
  ## Examples
      iex> find_or_create_end_user("end_user_id", "org_client_id")
      {:ok, %EndUser{}}
  """
  def find_or_create_end_user(end_user_id, org_client_id) do
    case get_org_by_client_id(org_client_id) do
      {:error, _} ->
        {:error, :not_found}
      {:ok, org} ->
        case Repo.get(EndUser, end_user_id) do
          nil ->
            %EndUser{}
            |> EndUser.changeset(%{ id: end_user_id })
            |> Ecto.Changeset.put_assoc(:org, org)
            |> Repo.insert()
          end_user ->
            {:ok, end_user}
        end
    end
  end

  def get_end_user(end_user_id, org_id) do
    case Repo.get_by(EndUser, %{ id: end_user_id, org_id: org_id }) do
      nil -> {:error, :not_found}
      end_user -> {:ok, end_user}
    end
  end

  def get_end_user!(id), do: Repo.get!(EndUser, id)

  def add_or_update_stripe_customer_id(user, token) do
    case user.stripe_customer_id do
      nil ->
        case Stripe.Customer.create(email: user.email) do
          {:ok, %{"id" => new_customer_id}} ->
            user
            |> User.changeset_without_pass(%{ stripe_customer_id: new_customer_id })
            |> Repo.update()
          {:error, errors} -> {:error, errors}
        end
      _ -> Stripe.Customer.update(user.stripe_customer_id, source: token)
    end
  end

  def add_or_update_stripe_plan(user, org, plan_id) do
    case get_org_gate(org.id, "stripe_subscription_id") do
      nil ->
        case Stripe.Subscription.create(
          customer: user.stripe_customer_id,
          items: [%{ "plan" => plan_id }],
          expand: ["latest_invoice.payment_intent"]
        ) do
          {:ok, %{ "id" => new_subscription_id }} ->
            %OrgProperty{
              name: "stripe_subscription_id",
              value: new_subscription_id,
              type: "string",
              namespace: "GATES",
              org_id: org.id
            }
            |> Repo.insert()
          {:error, errors} -> {:error, errors}
        end
      sub_id -> Stripe.Subscription.update(sub_id, items: [%{ "plan" => plan_id }, expand: ["latest_invoice.payment_intent"]])
    end
  end

  def get_org_subscription_id(org_id) do
    get_org_gate(org_id, "stripe_subscription_id")
  end

  def get_org_subscription(org_id) do
    case get_org_subscription_id(org_id) do
      nil -> nil
      prop ->
        case Stripe.Subscription.retrieve(prop.value) do
          {:error, _} -> nil
          {:ok, sub} -> sub
        end
    end
  end

  def get_invoice_for_org(org_id) do
    case get_org_subscription_id(org_id) do
      nil -> nil
      prop -> Subscription.get_invoice_for_subscription(prop.value)
    end
  end

  def record_event_track_by_client_id(client_id, event_id) do
    case get_org_by_client_id(client_id) do
      {:ok, org} ->
        case get_org_subscription(org.id) do
          nil -> {:error, :not_found}
          sub -> Subscription.record_event_for_subscription(sub, event_id)
        end
      {:error, :not_found} -> {:error, :not_found}
    end
  end


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

  def get_org(id), do: Repo.get(Org, id)

  def get_org_by_client_id_and_secret(client_id, client_secret) do
    case Repo.get_by(Org, client_id: client_id, client_secret: client_secret) do
      nil ->
        {:error, :not_found}
      org ->
        {:ok, org}
    end
  end

  def get_org_by_client_id(client_id) do
    case Repo.get_by(Org, client_id: client_id) do
      nil ->
        {:error, :not_found}
      org ->
        {:ok, org}
    end
  end

  def get_org_by_secret_id(secret_id) do
    case Repo.get_by(Org, client_secret: secret_id) do
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

  def get_properties_for_org(org_id) do
    Repo.all(from(o in OrgProperty, where: o.org_id == ^org_id))
  end

  def get_gates_for_org(org_id) do
    Repo.all(from(o in OrgProperty, where: o.org_id == ^org_id and o.namespace == "GATES"))
  end

  def upsert_org_property(org_id, name, value, type, namespace) do
    prop = Repo.get_by(OrgProperty, org_id: org_id, name: name, namespace: namespace)
    case prop == nil do
      false ->
        prop
        |> OrgProperty.changeset(%{ value: value, type: type })
        |> Repo.update()
      true ->
        %OrgProperty{
          name: name,
          value: value,
          type: type,
          namespace: namespace,
          org_id: org_id
        }
        |> Repo.insert()
    end
  end

  def upsert_org_gate(org_id, name, enabled) do
    upsert_org_property(org_id, name, enabled, "boolean", "GATES")
  end

  def get_org_gate(org_id, name) do
    Repo.get_by(OrgProperty, org_id: org_id, name: name, namespace: "GATES")
  end

  def upsert_org_setting(org_id, name, value, type) do
    upsert_org_property(org_id, name, value, type, "SETTINGS")
  end
end
