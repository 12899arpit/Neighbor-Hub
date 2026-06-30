defmodule NeighborHubWeb.UserController do
  use NeighborHubWeb, :controller

  alias NeighborHub.Accounts

  # GET /signup — just show the empty form
  def new(conn, _params) do
    changeset = Accounts.change_user(%NeighborHub.Accounts.User{})
    render(conn, :new, changeset: changeset)
  end

  # POST /signup — handle the form submission
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        # Success — save user id in session and redirect to home
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Welcome to NeighborHub, #{user.name}!")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        # Failure — re-render the form with errors
        render(conn, :new, changeset: changeset)

    end
  end

  # GET /login — show the login form
  def login(conn, _params) do
    render(conn, :login)
  end

  # POST /login — handle the login form submission
  def authenticate(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Welcome back, #{user.name}!")
        |> redirect(to: ~p"/")

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid email or password.")
        |> render(:login)
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: ~p"/login")
  end

end
