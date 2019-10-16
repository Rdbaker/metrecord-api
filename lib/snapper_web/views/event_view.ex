defmodule SnapperWeb.EventView do
  use SnapperWeb, :view
  alias SnapperWeb.EventView

  def render("browser_timers.json", %{browser_timers: browser_timers}) do
    %{data: render_many(browser_timers, EventView, "browser_timer.json")}
  end

  def render("browser_timer.json", %{event: event}) do
    %{
      dnsTime: event.dnsTime,
      tcpTime: event.tcpTime,
      ttfb: event.ttfb,
      serverTime: event.serverTime,
      tti: event.tti,
      domComplete: event.domComplete,
      domLoadCallbacks: event.domLoadCallbacks,
      minute: event.minute,
    }
  end

  def render("event_timers.json", %{event_timers: event_timers}) do
    %{data: render_many(event_timers, EventView, "event_timer.json")}
  end

  def render("event_timer.json", %{event: event}) do
    %{
      avg: event.avg,
      minute: event.minute,
    }
  end

  def render("events.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{
      org_id: event.org_id,
      created_at: event.inserted_at,
      name: event.name,
      event_type: event.event_type,
      end_user_id: event.end_user_id,
      dedup_key: event.dedup_key,
      data: event.data,
    }
  end
end
