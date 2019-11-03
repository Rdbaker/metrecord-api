defmodule Metrecord.Repo do
  use Ecto.Repo,
    otp_app: :metrecord,
    adapter: Ecto.Adapters.Postgres
end
