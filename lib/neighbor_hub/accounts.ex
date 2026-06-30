defmodule NeighborHub.Accounts do
  # This is the context — the ONLY place that talks to the User schema
  # Controllers and LiveViews never touch the DB directly, they call this module

  alias NeighborHub.Repo
  alias NeighborHub.Accounts.User

  # Get a single user by id
  def get_user(id), do: Repo.get(User, id)

  # Get a user by email (used during login)
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  # Create a new user (used during signup)
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # List all users
  def list_users do
    Repo.all(User)
  end


  # Authenticate a user by email and password
  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
        # No user found with that email
        user == nil ->
            {:error, :invalid_credentials}

        # User found, check password
        user.password_hash == Base.encode64(:crypto.hash(:sha256, password)) ->
            {:ok, user}

        # Password does not match
        true ->
            {:error, :invalid_password}
    end
  end

  def change_user(user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end
end
