defmodule MetrecordWeb.DashboardView do
  use MetrecordWeb, :view
  alias MetrecordWeb.DashboardView
  alias MetrecordWeb.ChartView
  alias MetrecordWeb.ChartDashboardView

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

  def render("hydrated_dashboard.json", %{ dashboard: dashboard, charts: charts, relations: relations }) do
    %{
      dashboard: render_one(dashboard, DashboardView, "dashboard.json"),
      charts: render_many(charts, ChartView, "chart.json"),
      relations: render_many(relations, ChartDashboardView, "chart_dashboard.json"),
    }
  end
end
