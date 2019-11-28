defmodule MetrecordWeb.OrgController do
  use MetrecordWeb, :controller

  alias Metrecord.Accounts

  def me(conn, _params) do
    org = Accounts.get_org! conn.assigns[:current_user].org_id
    org_properties = Accounts.get_properties_for_org(org.id)
    org_sub = Accounts.get_org_subscription(org.id)
    render(conn, "private.json", %{ org: org, org_properties: org_properties, subscription: org_sub })
  end

  def show_from_client_id(conn, %{"client_id" => client_id}) do
    case Accounts.get_org_by_client_id(client_id) do
      {:ok, org} ->
        org_properties = Accounts.get_properties_for_org(org.id)
        render(conn, "widget.json", %{ org: org, org_properties: org_properties })
      {:error, _} ->
        conn
        |> MetrecordWeb.FallbackController.call({:error, :not_found})
    end
  end
end
