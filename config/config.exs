# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :snapper,
  ecto_repos: [Snapper.Repo]

# Configures the endpoint
config :snapper, SnapperWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EcZAZU8IMQCtDg77fflIO/DtNCxtMsQqzLoH4IfJdpfHLHtNzHK5acCQVUbkCGLy",
  render_errors: [view: SnapperWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Snapper.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :snapper, Snapper.Guardian,
       issuer: "snapper",
       secret_key: "Secret key. You can use `mix guardian.gen.secret` to get one"