defmodule WebTextAuditerWeb.Router do
  use WebTextAuditerWeb, :router

  defp auth(conn, _opts) do
    username = Application.get_env(:web_text_auditer, BasicAuth)[:user]
    password = Application.get_env(:web_text_auditer, BasicAuth)[:secret]
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WebTextAuditerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WebTextAuditerWeb do
    pipe_through :browser

    live "/", Live.HomeLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebTextAuditerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:web_text_auditer, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WebTextAuditerWeb.Telemetry
    end
  end
end
