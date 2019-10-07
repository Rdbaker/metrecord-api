defmodule Snapper.Repo do
  use Ecto.Repo,
    otp_app: :snapper,
    adapter: Ecto.Adapters.Postgres
end
