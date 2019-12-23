defmodule MetrecordWeb.EventView do
  use MetrecordWeb, :view
  alias MetrecordWeb.EventView

  def render("series.json", %{ event_series: event_series }) do
    %{data: render_many(event_series, EventView, "series_point.json")}
  end

  def render("ajax_series.json", %{ event_series: event_series }) do
    %{data: render_many(event_series, EventView, "ajax_point.json")}
  end

  def render("ajax_point.json", %{ event: event }) do
    %{
      p99: event.p99,
      p95: event.p95,
      p90: event.p90,
      p50: event.p50,
      time: event.time,
    }
  end

  def render("series_point.json", %{ event: event }) do
    %{
      avg: event.avg,
      p99: event.p99,
      p95: event.p95,
      p90: event.p90,
      sum: event.sum,
      count: event.count,
      min: event.min,
      max: event.max,
      time: event.time,
    }
  end

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
      minute: event.minute
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
      id: event.id,
      name: event.name,
      event_type: event.event_type,
      end_user_id: event.end_user_id,
      dedup_key: event.dedup_key,
      data: event.data
    }
  end

  def render("has_any.json", %{ has_any: has_any }) do
    %{
      has_any_events: has_any
    }
  end

  def render("event_counts.json", %{ event_counts: event_counts }) do
    %{data: render_many(event_counts, EventView, "event_count.json")}
  end

  def render("event_count.json", %{ event: event_count }) do
    %{
      name: event_count.name,
      similarity: event_count.similarity,
      count: event_count.count,
      first_seen: event_count.first_seen,
      last_seen: event_count.last_seen
    }
  end
end
