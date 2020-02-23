defmodule MetrecordWeb.EmailController do
  use MetrecordWeb, :controller

  alias Metrecord.Accounts

  def welcome(conn, %{ "user_id" => user_id }) do
    user = Accounts.get_user! user_id
    case Metrecord.Guardian.encode_and_sign(user) do
      {:ok, token, _claims} ->
        app_host = Application.fetch_env!(:metrecord, :app_host)
        render(conn, "welcome_email.html", user: user, app_host: app_host, token: token)
    end
  end
end
