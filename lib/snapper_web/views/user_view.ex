defmodule SnapperWeb.UserView do
  import SnapperWeb.ErrorHelpers

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
    %{email: user.email, name: user.name}
  end
end
