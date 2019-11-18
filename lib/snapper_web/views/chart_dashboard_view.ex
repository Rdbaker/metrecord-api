defmodule MetrecordWeb.ChartDashboardView do
  use MetrecordWeb, :view

  def render("chart_dashboard.json", %{chart_dashboard: chart_dashboard}) do
    %{
      chart_id: chart_dashboard.chart_id,
      dashboard_id: chart_dashboard.dashboard_id,
      config: chart_dashboard.config,
    }
  end
end
