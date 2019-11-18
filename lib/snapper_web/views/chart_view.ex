defmodule MetrecordWeb.ChartView do
  use MetrecordWeb, :view
  alias MetrecordWeb.ChartView

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

  def render("paginate.json", %{ page: page, page_number: page_number, page_size: page_size, total_pages: total_pages }) do
    %{
      page: render_many(page, ChartView, "chart.json"),
      page_number: page_number,
      page_size: page_size,
      total_pages: total_pages
    }
  end
end
