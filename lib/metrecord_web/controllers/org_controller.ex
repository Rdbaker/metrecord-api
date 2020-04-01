defmodule MetrecordWeb.OrgController do
  use MetrecordWeb, :controller

  alias Metrecord.Accounts

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

  def show_public_org(conn, _params) do
    org = conn.assigns[:current_org]
    org_properties = Accounts.get_properties_for_org(org.id)
    render(conn, "widget.json", %{ org: org, org_properties: org_properties })
  end

  def add_gate_to_org(conn, %{"id" => org_id, "name" => gate_name, "value" => value }) do
    is_admin = conn.assigns[:current_user].role == "uadmin" or conn.assigns[:current_user].role == "sadmin"
    {id, _} = Integer.parse(org_id)
    case is_admin do
      false -> conn
        |> send_resp(403, "Forbidden")
      true ->
        Accounts.upsert_org_gate(id, gate_name, value)
        org = Accounts.get_org!(id)
        gates = Accounts.get_gates_for_org(id)
        gate_values = Enum.map(gates, fn prop -> %{ "name" => prop.name, "namespace" => "GATES", "type" => prop.type, "value" => prop.value } end)
        MetrecordWeb.Endpoint.broadcast("orgs:" <> org.client_secret, "metrecord:update_gates", %{ "data" => gate_values })
        conn
        |> json(%{ "accepted" => true })
    end
  end
end
