defmodule MetrecordWeb.Router do
  use MetrecordWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :user_auth do
    plug Metrecord.Auth.UserTokenPlug
  end

  scope "/api", MetrecordWeb do
    pipe_through :api
  end

  # AUTH REQUIRED API ENDPOINTS
  scope "/api", MetrecordWeb do
    pipe_through [:api, :user_auth]

    get "/orgs/me", OrgController, :me

    # get "/org_properties/me", OrgPropertyController, :me
    # post "/org_properties", OrgPropertyController, :create_setting

    get "/users/me", UserController, :me
    get "/users/:id", UserController, :show

    get "/events", EventController, :query
    get "/events/:name/avg/minute", EventController, :minute_avg
    get "/events/typeahead", EventController, :search_by_name
    get "/events/has_any", EventController, :has_any
    get "/browser/performance/minute", EventController, :page_load_minute_breakdown
    get "/browser/performance/hour", EventController, :page_load_hour_breakdown
    get "/events/:name/series", EventController, :event_series

    post "/charts", ChartController, :create_chart
    get "/charts/:id", ChartController, :find_chart

    post "/dashboards", DashboardController, :create_dashboard
    get "/dashboards/:id", DashboardController, :find_dashboard
    get "/dashboards", DashboardController, :paginate
  end

  # PUBLIC API ENDPOINTS
  scope "/api", MetrecordWeb do
    pipe_through :api

    post "/users", UserController, :create
    post "/sessions", SessionController, :create
    get "/sessions", SessionController, :create
  end

  scope "/widget", MetrecordWeb do
    pipe_through :api

    get "/orgs/:client_id", OrgController, :show_from_client_id
  end
end
