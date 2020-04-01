defmodule MetrecordWeb.OrgPropertyController do
  use MetrecordWeb, :controller

  alias Metrecord.Accounts

  def me(conn, _params) do
    conn
    |> put_view(MetrecordWeb.PropertyView)
    |> render("show.json", org_properties: Accounts.get_properties_for_org(conn.assigns[:current_user].org_id))
  end

  def create_setting(conn, %{ "property" => %{ "name" => name, "value" => value, "type" => type, "namespace" => namespace }}) do
    # throw an error if they're trying to patch a gate
    org_id = conn.assigns[:current_user].org_id
    Accounts.upsert_org_property(org_id, name, value, type, namespace)
    conn
    |> put_view(MetrecordWeb.PropertyView)
    |> render("show.json", org_properties: Accounts.get_properties_for_org(org_id))
  end

  def create_setting(conn, %{ "property" => %{ "name" => name, "value" => value }}) do
    create_setting(conn, %{ "property" => %{ "name" => name, "value" => value, "type" => "string", "namespace" => "SETTINGS" }})
  end

  def create_setting(conn, %{ "property" => %{ "name" => name, "value" => value, "type" => type }}) do
    create_setting(conn, %{ "property" => %{ "name" => name, "value" => value, "type" => type, "namespace" => "SETTINGS" }})
  end
end
