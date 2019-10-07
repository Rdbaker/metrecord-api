defmodule SnapperWeb.Router do
  use SnapperWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :user_auth do
    plug Snapper.Auth.UserTokenPlug
  end

  scope "/api", SnapperWeb do
    pipe_through :api
  end

  # AUTH REQUIRED API ENDPOINTS
  scope "/api", SnapperWeb do
    pipe_through [:api, :user_auth]

    # get "/orgs/me", OrgController, :me

    # get "/org_properties/me", OrgPropertyController, :me
    # post "/org_properties", OrgPropertyController, :create_setting

    get "/users/me", UserController, :me
    get "/users/:id", UserController, :show
  end

  # PUBLIC API ENDPOINTS
  scope "/api", SnapperWeb do
    pipe_through :api

    post "/users", UserController, :create
    post "/sessions", SessionController, :create
    get "/sessions", SessionController, :create
  end
end
