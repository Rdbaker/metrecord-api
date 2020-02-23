# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :metrecord,
  ecto_repos: [Metrecord.Repo],
  app_host: "http://localhost:3200"

config :sendgrid,
  phoenix_view: MetrecordWeb.EmailView,
  api_key: "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"

# Configures the endpoint
config :metrecord, MetrecordWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EcZAZU8IMQCtDg77fflIO/DtNCxtMsQqzLoH4IfJdpfHLHtNzHK5acCQVUbkCGLy",
  render_errors: [view: MetrecordWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Metrecord.PubSub, adapter: Phoenix.PubSub.PG2]

config :stripe, :secret_key, "sk_test_XCyKOB0p9qxwfBMlsCSI1azz004ciu6eQT"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :metrecord, Metrecord.Guardian,
       issuer: "metrecord",
       secret_key: "Secret key. You can use `mix guardian.gen.secret` to get one"
