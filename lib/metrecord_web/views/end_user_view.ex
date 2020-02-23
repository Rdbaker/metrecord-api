defmodule MetrecordWeb.EndUserView do
  use MetrecordWeb, :view
  alias MetrecordWeb.EndUserView
  alias MetrecordWeb.EventView

  def render("fake_page.json", %{fake_page: fake_page}) do
    %{data: render_many(fake_page, EndUserView, "end_user.json")}
  end

  def render("end_user.json", %{end_user: end_user}) do
    %{
      end_user_id: end_user.end_user_id,
      event_count: end_user.event_count,
      last_seen: end_user.last_seen
    }
  end

  def render("events.json", %{ end_user_events: events }) do
    %{data: render_many(events, EventView, "event.json")}
  end
end
