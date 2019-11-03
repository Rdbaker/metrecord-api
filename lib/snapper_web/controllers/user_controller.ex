defmodule MetrecordWeb.UserController do
  use MetrecordWeb, :controller

  alias Metrecord.Accounts.User
  alias Metrecord.Accounts

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        case Accounts.authenticate_by_email_password(user_params["email"], user_params["password"]) do
          {:ok, user} ->
            case Metrecord.Guardian.encode_and_sign(user) do
              {:ok, token, claims} ->
                render(conn, "show_token.json", %{ token: token, claims: claims })
            end
          {:error, :unauthorized} ->
            conn
            |> put_status(400)
            |> render("error.json", %{ error: "unauthorized" })
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "error.json", changeset: changeset)
    end
  end

  def me(conn, _params) do
    render(conn, "show.json", user: conn.assigns[:current_user])
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end
end
