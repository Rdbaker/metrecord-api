defmodule Metrecord.Events.ChartDashboard do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "charts_dashboards" do
    field :chart_id, :binary_id, primary_key: true
    field :dashboard_id, :binary_id, primary_key: true
    field :config, :map
  end

  @doc false
  def changeset(assoc, attrs) do
    assoc
    |> cast(attrs, [:config])
    |> validate_required([:config])
  end
end
