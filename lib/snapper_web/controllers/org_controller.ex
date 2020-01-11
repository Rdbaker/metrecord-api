defmodule MetrecordWeb.OrgController do
  use MetrecordWeb, :controller

  alias Metrecord.Accounts
  alias MetrecordWeb.ErrorView

  def me(conn, _params) do
    org = Accounts.get_org! conn.assigns[:current_user].org_id
    org_properties = Accounts.get_properties_for_org(org.id)
    org_sub = Accounts.get_org_subscription(org.id)
    render(conn, "private.json", %{ org: org, org_properties: org_properties, subscription: org_sub })
  end

  def view_my_invoice(conn, _params) do
    org = Accounts.get_org! conn.assigns[:current_user].org_id
    case Accounts.get_invoice_for_org(org.id) do
      nil -> conn
        |> put_status(404)
        |> render("error.json", %{ error: "not found" })
      invoice -> render(conn, "current_invoice.json", %{ invoice: invoice })
    end
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

  def add_gate_to_org(conn, %{"id" => org_id, "name" => gate_name }) do
    is_admin = conn.assigns[:current_user].org_id == 1
    {id, _} = Integer.parse(org_id)
    case is_admin do
      false -> conn
        |> send_resp(403, "Forbidden")
      true ->
        Accounts.upsert_org_gate(id, gate_name, "true")
        conn
        |> json(%{ "accepted" => true })
    end
  end
end
