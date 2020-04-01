defmodule MetrecordWeb.PropertyView do
  use MetrecordWeb, :view
  alias MetrecordWeb.PropertyView

  def render("show.json", %{org_properties: properties}) do
    %{data: render_many(properties, PropertyView, "property.json")}
  end

  def render("show.json", %{user_properties: properties}) do
    %{data: render_many(properties, PropertyView, "property.json")}
  end

  def render("show.json", %{end_user_properties: properties}) do
    %{data: render_many(properties, PropertyView, "property.json")}
  end

  def render("property.json", %{property: property}) do
    %{
      name: property.name,
      namespace: property.namespace,
      value: property.value,
      type: property.type
    }
  end
end
