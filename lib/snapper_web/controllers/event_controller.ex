defmodule SnapperWeb.EventController do
  use SnapperWeb, :controller

  alias Snapper.Events

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
end
