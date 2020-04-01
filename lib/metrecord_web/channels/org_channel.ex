defmodule MetrecordWeb.OrgChannel do
  use Phoenix.Channel

  alias Metrecord.Accounts

  # TODO: auth this
  def join("orgs:" <> org_secret, _params, socket) do
    case Accounts.get_org_by_secret_id(org_secret) do
      {:ok, _org} -> {:ok, socket}
      {:error, _} -> {:error, socket}
    end
  end

end
