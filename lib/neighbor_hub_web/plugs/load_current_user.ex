defmodule NeighborHubWeb.Plugs.LoadCurrentUser do
  import Plug.Conn
  alias NeighborHub.Accounts

  # Every plug must have init/1 — we don't need it to do anything
  def init(opts), do: opts


  # call/2 is what actually runs on every request
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    # ↑ read the :user_id we saved during login/signup

    cond do
      # Already loaded in this request — skip
      conn.assigns[:current_user] ->
        conn

      # Session has a user_id — load the user from DB
      user_id ->
        user = Accounts.get_user(user_id)
        assign(conn, :current_user, user)
        # ↑ assign() puts current_user on the conn
        # now every controller and template can access @current_user

      # No session — assign nil so templates don't crash
      true ->
        assign(conn, :current_user, nil)
    end
  end
end
