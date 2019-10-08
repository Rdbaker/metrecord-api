defmodule SnapperWeb.OrgController do
  use SnapperWeb, :controller

  alias Snapper.Accounts

  def show_from_client_id(conn, %{"client_id" => client_id}) do
    case Accounts.get_org_by_client_id(client_id) do
      {:ok, org} ->
        render(conn, "widget.json", %{ org: org })
      {:error, _} ->
        conn
        |> SnapperWeb.FallbackController.call({:error, :not_found})
    end
  end
end
