defmodule MetrecordWeb.EventController do
  use MetrecordWeb, :controller

  alias Metrecord.Events
  alias MetrecordWeb.ErrorView

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

  def ajax_series(conn, %{ "start_date" => start_date, "end_date" => end_date, "interval" => interval }) do
    user = conn.assigns[:current_user]
    case interval in ["second", "minute", "hour", "day", "week", "month", "year"] do
      true ->
        event_series = Events.ajax_series(user.org_id, start_date, end_date, interval)
        render(conn, "ajax_series.json", %{ event_series: event_series })
      false -> {:error, :bad_request}
    end
  end

  def find(conn, %{ "id" => event_id }) do
    user = conn.assigns[:current_user]
    case Events.find_event(user.org_id, event_id) do
      {:error, :not_found} -> conn
        |> put_view(ErrorView)
        |> put_status(404)
        |> render("400.json", %{ error_message: "Could not find that event" })
      event -> render(conn, "event.json", %{ event: event })
    end
  end

  def ajax_points(conn, %{ "start_date" => start_date, "end_date" => end_date }) do
    user = conn.assigns[:current_user]
    events = Events.ajax_points(user.org_id, start_date, end_date)
    render(conn, "events.json", %{ events: events })
  end

  def page_load_summary(conn, %{ "start_date" => start_date, "end_date" => end_date }) do
    user = conn.assigns[:current_user]
    summary = Events.page_load_summary(user.org_id, start_date, end_date, "year")
    render(conn, "page_load_summary.json", %{ summary: summary })
  end

  def browser_error_rate(conn, %{ "start_date" => start_date, "end_date" => end_date, "interval" => interval }) do
    user = conn.assigns[:current_user]
    error_histogram = Events.browser_error_count(user.org_id, start_date, end_date, interval)
    render(conn, "error_rate_summary.json", %{ histogram: error_histogram })
  end
end
