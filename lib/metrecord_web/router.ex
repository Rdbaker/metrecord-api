defmodule MetrecordWeb.Router do
  use MetrecordWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :user_auth do
    plug Metrecord.Auth.UserTokenPlug
  end

  pipeline :client do
    plug :accepts, ["json"]
    plug Metrecord.Auth.ClientIdPlug
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

    patch "/orgs/:id/gates/:name", OrgController, :add_gate_to_org
  end

  # PUBLIC API ENDPOINTS
  scope "/api", MetrecordWeb do
    pipe_through :api

    post "/users", UserController, :create
    post "/sessions", SessionController, :create
    get "/sessions", SessionController, :create
    post "/events", EventController, :create_track_event
    post "/users/verify", UserController, :verify
    post "/users/report-false-email", UserController, :report_false_email
  end

  scope "/emails", MetrecordWeb do
    pipe_through :browser

    get "/welcome", EmailController, :welcome
  end

  scope "/widget", MetrecordWeb do
    pipe_through :client

    get "/orgs/me", OrgController, :show_public_org
  end
end
