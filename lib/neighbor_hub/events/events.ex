defmodule NeighborHub.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias NeighborHub.Accounts.User

  schema "events" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :date, :naive_datetime

    belongs_to :user, User
    # ↑ this tells Ecto: every event belongs to a user
    # it expects a user_id column in the table (which we added in migration)
    # now you can do event.user to get the full user struct


    timestamps()
  end


  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :description, :location, :date, :user_id])
    |> validate_required([:title, :location, :date, :user_id])
    |> validate_length(:title, min: 3, max: 100)
    |> assoc_constraint(:user)
    # ↑ validates that the user_id actually exists in the users table
  end

end
