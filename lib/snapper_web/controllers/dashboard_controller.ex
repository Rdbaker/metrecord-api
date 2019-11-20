defmodule MetrecordWeb.DashboardController do
  use MetrecordWeb, :controller

  alias Metrecord.Events
  alias MetrecordWeb.ErrorView
  alias Metrecord.Paginator

  def create_dashboard(conn, %{ "dashboard" => dash_params, "associations" => associations }) do
    user = conn.assigns[:current_user]
    case Events.create_dashboard(user.org_id, dash_params) do
      {:ok, dashboard} ->
        Enum.each(associations, fn assoc -> Events.associate_chart_with_dashboard(assoc["chartId"], dashboard.id, assoc["config"]) end)
        render(conn, "hydrated_dashboard.json", Events.hydrated_dashboard(user.org_id, dashboard.id))
      z ->
        IO.inspect z
        conn
        |> put_view(ErrorView)
        |> put_status(400)
        |> render("400.json", %{ error_message: "Could not create a new dashboard" })
    end
  end

  def find_dashboard(conn, %{ "id" => dash_id }) do
    user = conn.assigns[:current_user]
    case Events.find_dashboard(user.org_id, dash_id) do
      nil -> conn
        |> put_view(ErrorView)
        |> put_status(404)
        |> render("400.json", %{ error_message: "Could not find that dashboard" })
      dashboard -> render(conn, "dashboard.json", %{ dashboard: dashboard })
    end
  end

  def find_hydrated_dashboard(conn, %{ "id" => dash_id }) do
    user = conn.assigns[:current_user]
    case Events.find_dashboard(user.org_id, dash_id) do
      nil -> conn
        |> put_view(ErrorView)
        |> put_status(404)
        |> render("400.json", %{ error_message: "Could not find that dashboard" })
      _ -> conn
        |> render("hydrated_dashboard.json", Events.hydrated_dashboard(user.org_id, dash_id))
    end
  end

  def paginate(conn, params) do
    user = conn.assigns[:current_user]
    paginator = Events.all_dashboards_query(user.org_id)
      |> Paginator.new(params)
    render(conn, "paginate.json",
      %{ page: paginator.entries,
          page_number: paginator.page_number,
          page_size: paginator.page_size,
          total_pages: paginator.total_pages })
  end

  def add_chart(conn, %{ "id" => dash_id, "chart_id" => chart_id }) do
    user = conn.assigns[:current_user]
    case Events.find_dashboard(user.org_id, dash_id) do
      nil -> conn
        |> put_view(ErrorView)
        |> put_status(404)
        |> render("400.json", %{ error_message: "Could not find that dashboard" })
      _ ->
        case Events.find_chart(user.org_id, chart_id) do
          nil -> conn
            |> put_view(ErrorView)
            |> put_status(404)
            |> render("400.json", %{ error_message: "Could not find that chart" })
          _ ->
            Events.associate_chart_with_dashboard(chart_id, dash_id)
            render(conn, "hydrated_dashboard.json", Events.hydrated_dashboard(user.org_id, dash_id))
        end
    end
  end

  def remove_chart(conn, %{ "id" => dash_id, "chart_id" => chart_id }) do
    user = conn.assigns[:current_user]
    case Events.find_dashboard(user.org_id, dash_id) do
      nil -> conn
        |> put_view(ErrorView)
        |> put_status(404)
        |> render("400.json", %{ error_message: "Could not find that dashboard" })
      _ ->
        case Events.find_chart(user.org_id, chart_id) do
          nil -> conn
            |> put_view(ErrorView)
            |> put_status(404)
            |> render("400.json", %{ error_message: "Could not find that chart" })
          _ ->
            Events.disassociate_chart_with_dashboard(chart_id, dash_id)
            render(conn, "hydrated_dashboard.json", Events.hydrated_dashboard(user.org_id, dash_id))
        end
    end
  end
end
