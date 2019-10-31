defmodule SnapperWeb.DashboardView do
  use SnapperWeb, :view
  alias SnapperWeb.DashboardView

  def render("dashboards.json", %{dashboards: dashboards}) do
    %{data: render_many(dashboards, DashboardView, "dashboard.json")}
  end

  def render("dashboard.json", %{dashboard: dashboard}) do
    %{
      id: dashboard.id,
      name: dashboard.name,
      config: dashboard.config,
      meta: dashboard.meta,
    }
  end

  def render("paginate.json", %{ page: page, page_number: page_number, page_size: page_size, total_pages: total_pages }) do
    %{
      page: render_many(page, DashboardView, "dashboard.json"),
      page_number: page_number,
      page_size: page_size,
      total_pages: total_pages
    }
  end
end
