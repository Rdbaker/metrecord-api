defmodule SnapperWeb.DashboardController do
  use SnapperWeb, :controller

  alias Snapper.Events
  alias SnapperWeb.ErrorView
  alias Snapper.Paginator

  def create_dashboard(conn, %{ "dashboard" => dash_params }) do
    user = conn.assigns[:current_user]
    case Events.create_dashboard(user.org_id, dash_params) do
      {:ok, dashboard} -> render(conn, "dashboard.json", %{ dashboard: dashboard })
      _ -> conn
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
end
