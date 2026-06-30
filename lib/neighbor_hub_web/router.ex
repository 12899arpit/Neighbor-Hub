defmodule NeighborHubWeb.Router do
  use NeighborHubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NeighborHubWeb.Layouts, :root}
    plug :put_layout, {NeighborHubWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NeighborHubWeb.Plugs.LoadCurrentUser # added out current user plug to the browser pipeline so that it runs for all browser requests
  end

  pipeline :require_auth do
    plug :require_authenticated_user
  end # this pipeline ensures that the user is authenticated or logged in before accessing certain routes or we can say features of our application. If the user is not authenticated, it will redirect them to the login page or show an error message.

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NeighborHubWeb do
    pipe_through :browser

    get "/", PageController, :home


    #Authentication Routes
    get "/signup", UserController, :new # show the signup form
    post "/signup", UserController, :create # handle the form submission
    get "/login", UserController, :login # show the login form
    post "/login", UserController, :authenticate # handle the login form submission
    delete "/logout", UserController, :logout # handle the logout request


    # Event Routes
    get "/events", EventController, :index
    get "/events/new", EventController, :new #show create event form
    live "/events/:id", EventLive
  end

  # Protected routes — must be logged in
  scope "/", NeighborHubWeb do
    pipe_through [:browser, :require_auth]
    post   "/events",           EventController, :create  # save new event
    delete "/events/:id",       EventController, :delete  # delete event

  end

  scope "/api", NeighborHubWeb do
    pipe_through :api
    # :api pipeline is already defined by Phoenix — it accepts JSON, no CSRF

    post "/token", ApiTokenController, :create
    # ↑ login via API, get a token back

    get "/events", ApiEventController, :index
    get "/events/:id", ApiEventController, :show

    post "/events", ApiEventController, :create


  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:neighbor_hub, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NeighborHubWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp require_authenticated_user(conn, _opts) do
    # import Phoenix.VerifiedRoutes
    if conn.assigns[:current_user] do
      conn
      # user is logged in — let the request through
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You must log in to access this page.")
      |> Phoenix.Controller.redirect(to: "/login")
      |> halt()
      # halt() stops the plug chain — no controller runs after this
    end
  end
end
