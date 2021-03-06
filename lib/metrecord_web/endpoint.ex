defmodule MetrecordWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :metrecord

  socket "/socket", MetrecordWeb.UserSocket,
    # heroku has a 55 second timeout window, change this to websocket: true when we get off heroku
    websocket: [timeout: 45_000],
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :metrecord,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_metrecord_key",
    signing_salt: "9v7SbCbT"

    plug CORSPlug, origin: ["http://localhost:9001", "http://localhost:3200", "https://js.metrecord.com", "https://app.metrecord.com", "https://www.metrecord.com"], headers: [
      "X-Metrecord-Client-Id",
      "Authorization",
      "Content-Type",
      "Accept",
      "Origin",
      "User-Agent",
      "DNT",
      "Cache-Control",
      "X-Mx-ReqToken",
      "Keep-Alive",
      "X-Requested-With",
      "If-Modified-Since",
      "X-CSRF-Token"
    ]

  plug MetrecordWeb.Router
end
