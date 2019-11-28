defmodule MetrecordWeb.OrgView do
  use MetrecordWeb, :view
  alias MetrecordWeb.OrgView
  alias MetrecordWeb.OrgPropertyView

  def render("widget.json", %{org: org, org_properties: org_properties}) do
    %{data: %{
      org: render_one(org, OrgView, "org.json"),
      properties: render_many(org_properties, OrgPropertyView, "property.json"),
    }}
  end

  def render("org.json", %{org: org}) do
    %{id: org.id, created_at: org.inserted_at, client_id: org.client_id}
  end

  def render("private.json", %{org: org, org_properties: org_properties, subscription: subscription }) do
    %{data: %{
        org: %{
          id: org.id,
          created_at: org.inserted_at,
          client_id: org.client_id,
          client_secret: org.client_secret,
        },
        properties: render_many(org_properties, OrgPropertyView, "property.json"),
        subscription: subscription,
      }
    }
  end
end
