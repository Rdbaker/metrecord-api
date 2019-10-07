defmodule Snapper.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, "{\"error\" : \"#{body}\"}") # todo: this is bad
  end
end
