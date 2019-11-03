defmodule MetrecordWeb.ChartController do
  use MetrecordWeb, :controller

  alias Metrecord.Events
  alias MetrecordWeb.ErrorView

  def create_chart(conn, %{ "chart" => chart_params }) do
    user = conn.assigns[:current_user]
    case Events.create_chart(user.org_id, chart_params) do
      {:ok, chart} -> render(conn, "chart.json", %{ chart: chart })
      _ -> {:error, :not_found} # this isn't the right error
    end
  end

  def find_chart(conn, %{ "id" => chart_id }) do
    user = conn.assigns[:current_user]
    case Events.find_chart(user.org_id, chart_id) do
      nil -> conn
        |> put_view(ErrorView)
        |> put_status(404)
        |> render("400.json", %{ error_message: "Could not find that chart" })
      chart -> render(conn, "chart.json", %{ chart: chart })
    end
  end
end
