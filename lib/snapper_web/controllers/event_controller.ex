defmodule MetrecordWeb.EventController do
  use MetrecordWeb, :controller

  alias Metrecord.Events

  def query(conn, %{ "start_date" => start_date, "end_date" => end_date, "event_type" => event_type, "name" => event_name}) do
    user = conn.assigns[:current_user]
    events = Events.get_events(user.org_id, start_date, end_date, event_type, event_name)
    render(conn, "events.json", %{ events: events })
  end

  def minute_avg(conn, %{ "start_date" => start_date, "end_date" => end_date, "name" => event_name}) do
    user = conn.assigns[:current_user]
    events = Events.get_avg_for_timer(user.org_id, start_date, end_date, event_name)
    render(conn, "event_timers.json", %{ event_timers: events })
  end

  def page_load_minute_breakdown(conn, %{ "start_date" => start_date, "end_date" => end_date}) do
    user = conn.assigns[:current_user]
    events = Events.get_browser_timing(user.org_id, start_date, end_date)
    render(conn, "browser_timers.json", %{ browser_timers: events })
  end

  def page_load_hour_breakdown(conn, %{ "start_date" => start_date, "end_date" => end_date}) do
    user = conn.assigns[:current_user]
    events = Events.get_browser_hour_timing(user.org_id, start_date, end_date)
    render(conn, "browser_timers.json", %{ browser_timers: events })
  end

  def has_any(conn, _params) do
    user = conn.assigns[:current_user]
    has_any = Events.has_any(user.org_id)
    render(conn, "has_any.json", %{ has_any: has_any })
  end

  def search_by_name(conn, %{ "name" => name_like }) do
    user = conn.assigns[:current_user]
    event_counts = Events.search_events_by_name(user.org_id, name_like)
    render(conn, "event_counts.json", %{ event_counts: event_counts })
  end

  def event_series(conn, %{ "name" => event_name, "start_date" => start_date, "end_date" => end_date, "interval" => interval }) do
    user = conn.assigns[:current_user]
    case interval in ["second", "minute", "hour", "day", "week", "month", "year"] do
      true ->
        event_series = Events.event_series(user.org_id, event_name, start_date, end_date, interval)
        render(conn, "series.json", %{ event_series: event_series })
      false -> {:error, :bad_request}
    end
  end
end
