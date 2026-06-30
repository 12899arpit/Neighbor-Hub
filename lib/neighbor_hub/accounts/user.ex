defmodule NeighborHub.Accounts.User do
    use Ecto.Schema
    import Ecto.Changeset

    # This tells Ecto: this module maps to the "users" table
        schema "users" do
        field :name,          :string
        field :email,         :string
        field :password_hash, :string

        # :virtual means this field does NOT exist in the database
        # It only lives in memory while we're processing a form
        # We use it to receive the plain password, hash it, then throw it away
        field :password,      :string, virtual: true

        timestamps()
    end

    def registration_changeset(user, attrs) do
        user
        |> cast(attrs, [:name, :email, :password])
        # cast() says: "from attrs, only pick these fields and put them on the struct"

        |> validate_required([:name, :email, :password])
        # validate_required() says: "these fields must not be blank"

        |> validate_format(:email, ~r/@/)
        # validate_format() says: "email must contain @"

        |> validate_length(:password, min: 6)
        # password must be at least 6 characters

        |> unique_constraint(:email)
        # if the DB unique_index fires, turn it into a friendly error on the changeset

        |> put_password_hash()
        # our custom function below — hash the password before saving
    end

    defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
        # Only hash if the changeset is valid AND password was actually changed
        change(changeset, password_hash: Base.encode64(:crypto.hash(:sha256, password)))
    end

    defp put_password_hash(changeset) do
        # If changeset is invalid or no password change, just return it unchanged
        changeset
    end
end
