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

  def get_events(org_id, start_date, end_date, event_type, event_name) do
    case Accounts.get_org(org_id) do
      nil -> {:error, :not_found}
      _ -> Repo.all(from(e in Event,
        where: e.org_id == ^org_id
          and e.inserted_at >= ^start_date
          and e.inserted_at < ^end_date
          and e.name == ^event_name
          and e.event_type == ^event_type,
        order_by: [desc: e.inserted_at]
      ))
    end
  end

  def get_events_for_end_user(org_id, end_user_id) do
    case Accounts.get_end_user(end_user_id, org_id) do
      {:error, _} -> {:error, :not_found}
      {:ok, _} -> Repo.all(from(e in Event,
        where: e.org_id == ^org_id
          and e.end_user_id == ^end_user_id,
        order_by: [desc: e.inserted_at]
      ))
    end
  end

  def get_avg_for_timer(org_id, start_date, end_date, event_name) do
    query = from(
      e in Event,
      where: e.event_type == ^"timer"
        and e.name == ^event_name
        and e.org_id == ^org_id
        and e.inserted_at >= ^start_date
        and e.inserted_at < ^end_date,
      select: [
        avg(fragment("(?->>'time_ms')::real", e.data)),
        fragment("date_trunc('minute', ?) as minute", e.inserted_at)
      ],
      group_by: fragment("date_trunc('minute', ?)", e.inserted_at),
      order_by: [desc: fragment("minute")],
    )
    Enum.map Repo.all(query), fn [avg, minute] -> %{ avg: avg, minute: minute } end
  end
end