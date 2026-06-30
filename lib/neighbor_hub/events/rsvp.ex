defmodule NeighborHub.Events.Rsvp do
  use Ecto.Schema
  import Ecto.Changeset

  alias NeighborHub.Accounts.User
  alias NeighborHub.Events.Event

  schema "rsvps" do
    belongs_to :user, User
    belongs_to :event, Event

    timestamps()
  end

  def changeset(rsvp, attrs) do
    rsvp
    |> cast(attrs, [:user_id, :event_id])
    |> validate_required([:user_id, :event_id])
    |> unique_constraint([:user_id, :event_id])
    # ↑ if same user tries to RSVP twice, returns a friendly error
  end
end
