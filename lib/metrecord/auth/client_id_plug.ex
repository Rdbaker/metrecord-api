defmodule Metrecord.Auth.ClientIdPlug do
  import Plug.Conn
  alias Metrecord.Accounts


  def init(_), do: []

  def call(conn, config) do
    conn
      |> fetch_query_params
      |> get_param
      |> handle_request(conn, config)
  end

  defp get_param(conn) do
    get_req_header(conn, "x-metrecord-client-id")
  end

  defp handle_request(client_id_list, conn, _config) do
    case Enum.at(client_id_list, 0) do
      nil ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, "{\"error\": \"bad request\", \"message\": \"no x-metrecord-client-id header supplied\"}")
        |> halt
      client_id ->
        case Accounts.get_org_by_client_id(client_id) do
          {:ok, org} ->
            assign(conn, :current_org, org)
          {:error, _} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(401, "{\"error\": \"bad request\", \"message\": \"could not find org from x-metrecord-client-id header\"}")
            |> halt
        end
    end
  end
end
