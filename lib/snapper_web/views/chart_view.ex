defmodule SnapperWeb.ChartView do
  use SnapperWeb, :view
  alias SnapperWeb.ChartView

  def render("charts.json", %{charts: charts}) do
    %{data: render_many(charts, ChartView, "chart.json")}
  end

  def render("chart.json", %{chart: chart}) do
    %{
      id: chart.id,
      name: chart.name,
      config: chart.config,
      meta: chart.meta,
    }
  end
end
