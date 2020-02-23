defmodule MetrecordWeb.SessionController do
  use MetrecordWeb, :controller

  alias Metrecord.Accounts

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        case Metrecord.Guardian.encode_and_sign(user) do
          {:ok, token, claims} ->
            render(conn, "show.json", %{ token: token, claims: claims })
        end
      {:error, :unauthorized} ->
        conn
        |> put_status(400)
        |> render("error.json", %{ error: "unauthorized" })
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
