defmodule NeighborHubWeb.ApiTokenController do
  use NeighborHubWeb, :controller

  alias NeighborHub.Accounts

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        # generate a simple token — user id signed with the app's secret key

        token = Phoenix.Token.sign(conn, "user_auth", user.id)


        conn
        |> put_status(:ok)
        |> json(%{token: token, user: %{id: user.id, email: user.email, name: user.name}})


      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end

  end

end
