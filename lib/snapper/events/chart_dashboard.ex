defmodule Snapper.Events.ChartDashboard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "charts_dashboards" do
    field :chart_id, :binary_id, primary_key: true
    field :dashboard_id, :binary_id, primary_key: true
    field :config, :map
    field :meta, :map
  end

  @doc false
  def changeset(assoc, attrs) do
    assoc
    |> cast(attrs, [:config, :meta])
    |> validate_required([:config, :meta])
  end
end
