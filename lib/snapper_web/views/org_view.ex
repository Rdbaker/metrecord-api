defmodule SnapperWeb.OrgView do
  use SnapperWeb, :view
  alias SnapperWeb.OrgView

  def render("widget.json", %{org: org}) do
    %{data: %{
      org: render_one(org, OrgView, "org.json"),
    }}
  end

  def render("org.json", %{org: org}) do
    %{id: org.id, created_at: org.inserted_at, client_id: org.client_id}
  end
end
