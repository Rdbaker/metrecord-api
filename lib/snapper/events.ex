defmodule Snapper.Events do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Snapper.Repo

  alias Snapper.Accounts
  alias Snapper.Accounts.EndUser
  alias Snapper.Events.Event
  alias Snapper.Events.Chart
  alias Snapper.Events.Dashboard
  alias Snapper.Events.ChartDashboard

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
      order_by: [desc: fragment("minute")]
    )
    Enum.map Repo.all(query), fn [avg, minute] -> %{ avg: avg, minute: minute } end
  end

  def get_browser_timing(org_id, start_date, end_date) do
    query = from(
      e in Event,
      where: e.event_type == ^"user_context"
        and e.org_id == ^org_id
        and e.inserted_at >= ^start_date
        and e.inserted_at < ^end_date
        and fragment("(?->'performance'->'timing'->>'domComplete' != '0')", e.data),
      select: [
        fragment("avg((?->'performance'->'timing'->>'domainLookupEnd')::bigint - (?->'performance'->'timing'->>'domainLookupStart')::bigint) as dnsTime", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'connectEnd')::bigint - (?->'performance'->'timing'->>'connectStart')::bigint) as tcpTime", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'responseStart')::bigint - (?->'performance'->'timing'->>'requestStart')::bigint) as ttfb", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'responseEnd')::bigint - (?->'performance'->'timing'->>'responseStart')::bigint) as serverTime", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'domInteractive')::bigint - (?->'performance'->'timing'->>'domLoading')::bigint) as tti", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'domComplete')::bigint - (?->'performance'->'timing'->>'domInteractive')::bigint) as domComplete", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'loadEventEnd')::bigint - (?->'performance'->'timing'->>'loadEventStart')::bigint) as domLoadCallbacks", e.data, e.data),
        fragment("date_trunc('minute', ?) as minute", e.inserted_at)
      ],
      group_by: fragment("date_trunc('minute', ?)", e.inserted_at),
      order_by: [desc: fragment("minute")]
    )
    Enum.map Repo.all(query), fn [dnsTime, tcpTime, ttfb, serverTime, tti, domComplete, domLoadCallbacks, minute] -> %{ dnsTime: dnsTime, tcpTime: tcpTime, ttfb: ttfb, serverTime: serverTime, tti: tti, domComplete: domComplete, domLoadCallbacks: domLoadCallbacks, minute: minute} end
  end

  def get_browser_hour_timing(org_id, start_date, end_date) do
    query = from(
      e in Event,
      where: e.event_type == ^"user_context"
        and e.org_id == ^org_id
        and e.inserted_at >= ^start_date
        and e.inserted_at < ^end_date
        and fragment("(?->'performance'->'timing'->>'domComplete' != '0')", e.data),
      select: [
        fragment("avg((?->'performance'->'timing'->>'domainLookupEnd')::bigint - (?->'performance'->'timing'->>'domainLookupStart')::bigint) as dnsTime", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'connectEnd')::bigint - (?->'performance'->'timing'->>'connectStart')::bigint) as tcpTime", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'responseStart')::bigint - (?->'performance'->'timing'->>'requestStart')::bigint) as ttfb", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'responseEnd')::bigint - (?->'performance'->'timing'->>'responseStart')::bigint) as serverTime", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'domInteractive')::bigint - (?->'performance'->'timing'->>'domLoading')::bigint) as tti", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'domComplete')::bigint - (?->'performance'->'timing'->>'domInteractive')::bigint) as domComplete", e.data, e.data),
        fragment("avg((?->'performance'->'timing'->>'loadEventEnd')::bigint - (?->'performance'->'timing'->>'loadEventStart')::bigint) as domLoadCallbacks", e.data, e.data),
        fragment("date_trunc('hour', ?) as hour", e.inserted_at)
      ],
      group_by: fragment("date_trunc('hour', ?)", e.inserted_at),
      order_by: [desc: fragment("hour")]
    )
    Enum.map Repo.all(query), fn [dnsTime, tcpTime, ttfb, serverTime, tti, domComplete, domLoadCallbacks, minute] -> %{ dnsTime: dnsTime, tcpTime: tcpTime, ttfb: ttfb, serverTime: serverTime, tti: tti, domComplete: domComplete, domLoadCallbacks: domLoadCallbacks, minute: minute} end
  end

  def has_any(org_id) do
    Repo.all(from e in Event, where: e.org_id == ^org_id, limit: 1) != nil
  end

  def search_events_by_name(org_id, name_like) do
    query = from(
      e in Event,
      where: fragment("? <% ?", ^name_like, e.name)
        and e.event_type != ^"user_context"
        and e.org_id == ^org_id,
      select: [
        e.name,
        fragment("similarity(?, ?) as similarity", ^name_like, e.name),
        fragment("count(*) as count"),
        fragment("min(inserted_at) as first_seen"),
        fragment("max(inserted_at) as last_seen")
      ],
      group_by: e.name,
      order_by: [desc: 2],
    )
    Enum.map Repo.all(query), fn [name, similarity, count, first_seen, last_seen] -> %{ name: name, similarity: similarity, count: count, first_seen: first_seen, last_seen: last_seen } end
  end

  def event_series(org_id, name, start_date, end_date, interval) do
    query = from(
      e in Event,
      where: e.event_type == ^"track"
        and e.name == ^name
        and e.inserted_at >= ^start_date
        and e.inserted_at < ^end_date
        and e.org_id == ^org_id,
      select: [
        fragment("sum((?->>'value')::bigint) as sum", e.data),
        fragment("avg((?->>'value')::bigint) as avg", e.data),
        fragment("count((?->>'value')::bigint) as count", e.data),
        fragment("min((?->>'value')::bigint) as min", e.data),
        fragment("max((?->>'value')::bigint) as max", e.data),
        fragment("date_trunc(?, ?) as time", ^interval, e.inserted_at)
      ],
      group_by: fragment("time"),
      order_by: [desc: fragment("time")]
    )
    Enum.map Repo.all(query), fn [sum, avg, count, min, max, time] -> %{ sum: sum, avg: avg, count: count, min: min, max: max, time: time} end
  end

  def create_chart(org_id, attrs \\ %{}) do
    case Accounts.get_org(org_id) do
      nil -> {:error, :not_found}
      org ->
        %Chart{}
        |> Chart.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:org, org)
        |> Repo.insert()
    end
  end

  def update_chart(%Chart{} = chart, attrs) do
    chart
    |> Chart.changeset(attrs)
    |> Repo.update()
  end

  def find_chart(org_id, chart_id) do
    Repo.get_by(Chart, org_id: org_id, id: chart_id)
  end

  def create_dashboard(org_id, attrs \\ %{}) do
    case Accounts.get_org(org_id) do
      nil -> {:error, :not_found}
      org ->
        %Dashboard{}
        |> Dashboard.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:org, org)
        |> Repo.insert()
    end
  end

  def update_dashboard(%Dashboard{} = dash, attrs) do
    dash
    |> Dashboard.changeset(attrs)
    |> Repo.update()
  end

  def find_dashboard(org_id, dash_id) do
    Repo.get_by(Dashboard, org_id: org_id, id: dash_id)
  end

  def all_dashboards_query(org_id) do
    from(d in Dashboard,
      where: d.org_id == ^org_id,
      order_by: [desc: d.inserted_at]
    )
  end

  def disassociate_chart_with_dashboard(chart_id, dashboard_id) do
    case Repo.get_by(ChartDashboard, chart_id: chart_id, dashboard_id: dashboard_id) do
      association -> Repo.delete association
      _ -> nil
    end
  end

  def associate_chart_with_dashboard(chart_id, dashboard_id) do
    case Repo.get_by(ChartDashboard, chart_id: chart_id, dashboard_id: dashboard_id) do
      association -> association
      nil ->
        %ChartDashboard{chart_id: chart_id, dashboard_id: dashboard_id}
        |> Repo.insert()
    end
  end

  def update_chart_dashboard_association(chart_id, dashboard_id, attrs) do
    associate_chart_with_dashboard(chart_id, dashboard_id)
    |> ChartDashboard.changeset(attrs)
    |> Repo.update()
  end
end
