defmodule MetrecordWeb.UserView do
  use MetrecordWeb, :view
  import MetrecordWeb.ErrorHelpers
  alias MetrecordWeb.UserView

  def render("index.json", _params) do
    %{allowed: false}
  end

  def render("show_token.json", %{ token: token, claims: claims }) do
    %{ token: token, claims: claims}
  end

  def render("error.json", %{:changeset => changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  def render("show.json", params) do
    %{data: render("user.json", params)}
  end

  def render("user.json", %{user: user}) do
    %{email: user.email, name: user.name, id: user.id, status: user.status, role: user.role}
  end

  def render("users_with_stripe.json", %{ users: users }) do
    %{data: render_many(users, UserView, "user_with_stripe.json")}
  end

  def render("user_with_stripe.json", %{ user: user }) do
    %{
      email: user.email,
      id: user.id,
      name: user.name,
      stripe_customer_id: user.stripe_customer_id,
      status: user.status,
      role: user.role
    }
  end
end
