defmodule Snapper.Plug.PublicIp do
  @moduledoc "Get public IP address of request from x-forwarded-for header"
  # credit where it's due: https://www.cogini.com/blog/getting-the-client-public-ip-address-in-phoenix/
  @behaviour Plug

  def init(opts), do: opts

  def call(%{assigns: %{ip: _}} = conn, _opts), do: conn
  def call(conn, _opts) do
    process(conn, Plug.Conn.get_req_header(conn, "x-forwarded-for"))
  end

  def process(conn, []) do
    Plug.Conn.assign(conn, :ip, to_string(:inet.ntoa(get_peer_ip(conn))))
  end
  def process(conn, vals) do
    ip_address = get_ip_address(conn, vals) # Rewrite standard remote_ip field with value from header
    # See https://hexdocs.pm/plug/Plug.Conn.html
    conn = %{conn | remote_ip: ip_address}

    Plug.Conn.assign(conn, :ip, to_string(:inet.ntoa(ip_address)))
  end

  defp get_ip_address(conn, vals)
  defp get_ip_address(conn, []), do: get_peer_ip(conn)
  defp get_ip_address(conn, [val | _]) do
    # Split into multiple values
    comps = val
      |> String.split(~r{\s*,\s*}, trim: true)
      |> Enum.filter(&(&1 != "unknown"))          # Get rid of "unknown" values
      |> Enum.map(&(hd(String.split(&1, ":"))))   # Split IP from port, if any
      |> Enum.filter(&(&1 != ""))                 # Filter out blanks
      |> Enum.map(&(parse_address(&1)))           # Parse address into :inet.ip_address tuple
      |> Enum.filter(&(is_public_ip(&1)))         # Elminate internal IP addreses, e.g. 192.168.1.1

    case comps do
      [] -> get_peer_ip(conn)
      [comp | _] -> comp
    end
  end

  @spec get_peer_ip(Plug.Conn.t) :: :inet.ip_address
  defp get_peer_ip(conn) do
    conn.remote_ip
  end

  @spec parse_address(String.t) :: :inet.ip_address
  defp parse_address(ip) do
    case :inet.parse_ipv4strict_address(to_charlist(ip)) do
      {:ok, ip_address} -> ip_address
      {:error, :einval} -> :einval
    end
  end

  # Whether the input is a valid, public IP address
  # http://en.wikipedia.org/wiki/Private_network
  @spec is_public_ip(:inet.ip_address | atom) :: boolean
  defp is_public_ip(ip_address) do
    case ip_address do
      {10, _, _, _}     -> false
      {192, 168, _, _}  -> false
      {172, second, _, _} when second >= 16 and second <= 31 -> false
      {127, 0, 0, _}    -> false
      {_, _, _, _}      -> true
      :einval           -> false
    end
  end
end
