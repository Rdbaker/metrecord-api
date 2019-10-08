defmodule Snapper.Events do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Snapper.Repo

  alias Snapper.Accounts
  alias Snapper.Accounts.EndUser
  alias Snapper.Accounts.Org
  alias Snapper.Events.Event

  @doc """
  Creates an event.
  """
  def create_event(client_id, end_user_id, attrs \\ %{}) do
    case Accounts.get_org_by_client_id(client_id) do
      {:error, :not_found} -> {:error, :not_found}
      {:ok, org} ->
        case Repo.get_by(EndUser, %{ id: end_user_id, org_id: org.id }) do
          nil -> {:error, :not_found}
          end_user ->
            %Event{}
            |> Event.changeset(attrs)
            |> Ecto.Changeset.put_assoc(:org, org)
            |> Ecto.Changeset.put_assoc(:end_user, end_user)
            |> Repo.insert()
        end
    end
  end
end
