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
    put "/orgs/update-plan", UserController, :update_my_plan
    get "/orgs/current-invoice", OrgController, :view_my_invoice

    # get "/org_properties/me", OrgPropertyController, :me
    # post "/org_properties", OrgPropertyController, :create_setting

    get "/users/me", UserController, :me
    get "/users/my_org", UserController, :my_org
    get "/users/:id", UserController, :show
    put "/users/payment-info", UserController, :update_my_payment_info

    get "/events", EventController, :query
    get "/events/pageLoads/summary", EventController, :page_load_summary
    get "/events/:name/avg/minute", EventController, :minute_avg
    get "/events/typeahead", EventController, :search_by_name
    get "/events/has_any", EventController, :has_any
    get "/browser/errors/rate", EventController, :browser_error_rate
    get "/browser/performance/minute", EventController, :page_load_minute_breakdown
    get "/browser/performance/hour", EventController, :page_load_hour_breakdown
    get "/events/:name/series", EventController, :event_series
    get "/events/:id", EventController, :find
    get "/ajax/series", EventController, :ajax_series
    get "/ajax/points", EventController, :ajax_points

    post "/charts", ChartController, :create_chart
    get "/charts/:id", ChartController, :find_chart
    get "/charts", ChartController, :paginate

    post "/dashboards", DashboardController, :create_dashboard
    get "/dashboards/:id", DashboardController, :find_dashboard
    get "/dashboards/:id/full", DashboardController, :find_hydrated_dashboard
    get "/dashboards", DashboardController, :paginate
    post "/dashboards/:id/add/:chart_id", DashboardController, :add_chart
    post "/dashboards/:id/remove/:chart_id", DashboardController, :remove_chart

    get "/end_users/fake_paginate", EndUserController, :fake_paginate
    get "/end_users/:id/events", EndUserController, :search_events_for_end_user
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
