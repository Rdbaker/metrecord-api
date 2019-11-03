defmodule Metrecord.Auth.UserTokenPlug do
  import Plug.Conn


  def init(_), do: []

  def call(conn, config) do
    conn
      |> fetch_query_params
      |> get_param
      |> handle_request(conn, config)
  end

  defp get_param(conn) do
    get_req_header(conn, "authorization")
  end

  defp handle_request(["Bearer " <> token | _], conn, config) do
    handle_request(token, conn, config)
  end

  defp handle_request(token, conn, _config) do
    case Metrecord.Guardian.resource_from_token(token) do
      {:ok, user, %{ "typ" => token_type }} ->
        case token_type do
          "access" ->
            conn
              |> assign(:current_user, user)
          _ ->
            conn
              |> send_resp(403, "Not Authorized")
              |> halt
        end
      {:error, _} ->
        conn
          |> send_resp(401, "Authentication Required")
          |> halt
    end
  end
end
