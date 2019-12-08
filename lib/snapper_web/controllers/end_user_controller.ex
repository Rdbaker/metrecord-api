defmodule MetrecordWeb.EndUserController do
  use MetrecordWeb, :controller

  alias Metrecord.Events

  def fake_paginate(conn, _params) do
    user = conn.assigns[:current_user]
    render(conn, "fake_page.json", fake_page: Events.group_by_end_user(user.org_id))
  end

  def search_events_for_end_user(conn, %{ "id" => end_user_id }) do
    user = conn.assigns[:current_user]
    render(conn, "events.json", end_user_events: Events.search_by_end_user(user.org_id, end_user_id))
  end

  def search_events_for_end_user(conn, %{ "id" => end_user_id, "before" => before }) do
    user = conn.assigns[:current_user]
    render(conn, "events.json", end_user_events: Events.search_by_end_user(user.org_id, end_user_id, before))
  end
end
