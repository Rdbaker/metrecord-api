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

  def render("current_invoice.json", %{ invoice: invoice }) do
    [line_item] = invoice["lines"]["data"]
    %{ data: %{
      country: invoice["account_country"],
      amount_due: invoice["amount_due"],
      amount_paid: invoice["amount_paid"],
      amount_remaining: invoice["amount_remaining"],
      attempt_count: invoice["attempt_count"],
      attempted: invoice["attempted"],
      billing_reason: invoice["billing_reason"],
      collection_method: invoice["collection_method"],
      created: invoice["created"],
      currency: invoice["currency"],
      customer: invoice["customer"],
      customer_email: invoice["customer_email"],
      cost: line_item["amount"],
      breakdown: line_item["description"],
      discountable: line_item["discountable"],
      period_end: line_item["period"]["end"],
      period_start: line_item["period"]["start"],
      events_used: line_item["quantity"],
    }}
  end
end
