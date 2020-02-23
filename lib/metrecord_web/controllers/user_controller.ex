defmodule MetrecordWeb.UserController do
  use MetrecordWeb, :controller

  alias Metrecord.Accounts
  alias MetrecordWeb.ErrorView
  alias MetrecordWeb.OrgView
  alias SendGrid.Email
  alias SendGrid.Mail

  def create(conn, %{"user" => user_params}) do
    processed_params = Map.put(user_params, "status", "unverified")
    case Accounts.create_user(processed_params) do
      {:ok, _user} ->
        case Accounts.authenticate_by_email_password(user_params["email"], user_params["password"]) do
          {:ok, user} ->
            case Metrecord.Guardian.encode_and_sign(user) do
              {:ok, token, claims} ->
                app_host = Application.fetch_env!(:metrecord, :app_host)
                Email.build()
                |> Email.add_to(user_params["email"])
                |> Email.put_from("welcome@hello.metrecord.com")
                |> Email.put_subject("Welcome to Metrecord! Please verify your email")
                |> Email.put_phoenix_template("welcome_email.html", user: user, app_host: app_host, token: token)
                |> Mail.send()
                render(conn, "show_token.json", %{ token: token, claims: claims })
            end
          {:error, :unauthorized} ->
            conn
            |> put_status(400)
            |> render("error.json", %{ error: "unauthorized" })
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> render("error.json", changeset: changeset)
    end
  end

  def verify(conn, %{ "token" => token }) do
    case Metrecord.Guardian.resource_from_token(token) do
      {:ok, user, %{ "typ" => token_type }} ->
        case token_type do
          "access" ->
            Accounts.update_user_status(user, "verified")
            render(conn, "user.json", user: user)
          _ ->
            conn
            |> put_status(403)
            |> render("error.json", %{ error: "Forbidden" })
        end
      {:error, _} ->
        conn
        |> put_status(401)
        |> render("error.json", %{ error: "Unauthorized" })
    end
  end

  def report_false_email(conn, %{ "userId" => user_id }) do
    case Accounts.get_user(user_id) do
      nil ->
        conn
        |> put_status(404)
        |> render("error.json", %{ error: "user not found" })
      user ->
        Accounts.update_user_status(user, "suspended")
        render(conn, "user.json", user: user)
    end
  end

  def me(conn, _params) do
    render(conn, "show.json", user: conn.assigns[:current_user])
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update_my_payment_info(conn, %{ "token" => stripe_token }) do
    user = conn.assigns[:current_user]
    case Accounts.add_or_update_stripe_customer_id(user, stripe_token) do
      {:ok, _} -> render(conn, "show.json", user: user)
      {:error, problem} -> conn
        |> put_view(ErrorView)
        |> put_status(400)
        |> render("400.json", %{ error_message: "Could not save payment info", details: problem })
    end
  end

  def update_my_plan(conn, %{ "plan" => plan_id }) do
    user = conn.assigns[:current_user]
    org = Accounts.get_org! user.org_id
    case Accounts.add_or_update_stripe_plan(user, org, plan_id) do
      {:ok, sub} ->
        org_properties = Accounts.get_properties_for_org(org.id)
        conn
        |> put_view(OrgView)
        |> render("private.json", %{ org: org, org_properties: org_properties, subscription: sub })
      {:error, problem} ->
        conn
        |> put_view(ErrorView)
        |> put_status(400)
        |> render("400.json", %{ error_message: "Could not update plan", details: problem })
    end
  end

  def my_org(conn, _params) do
    user = conn.assigns[:current_user]
    users = Accounts.get_all_in_org(user.org_id)
    render(conn, "users_with_stripe.json", %{ users: users })
  end
end
