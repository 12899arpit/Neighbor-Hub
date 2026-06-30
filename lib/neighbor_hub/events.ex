defmodule NeighborHub.Events do
  import Ecto.Query
  alias NeighborHub.Repo
  alias NeighborHub.Events.Event
  alias NeighborHub.Events.Rsvp


  # Get all events, newest first, with their creator loaded
  def list_events(page \\ 1, per_page \\ 6) do
    offset = (page - 1) * per_page

    events =
      Event
      |> order_by(desc: :inserted_at)
      |> preload(:user)
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()

    total_count = Repo.aggregate(Event, :count)
    total_pages = ceil(total_count / per_page)

    %{
      events: events,
      page: page,
      total_pages: total_pages,
      has_next: page < total_pages,
      has_prev: page > 1
    }
  end

  # Get a single event by id
  def get_event!(id) do
    Event
    |> preload(:user)
    |> Repo.get!(id)

    # Repo.get! with ! means: raise an error if not found (404)
    # Repo.get without ! returns nil if not found
  end

  # Create a new event with the given attributes
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  #delete an event
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end


  # Check if a user has already RSVPd to an event
  def rsvp_exists?(user_id, event_id) do
    Repo.exists?(
      from r in Rsvp,
      where: r.user_id == ^user_id and r.event_id == ^event_id
    )
    # ^ prefix means "this is a variable, not a column name"
  end

  # Create an RSVP
  def create_rsvp(user_id, event_id) do
    %Rsvp{}
    |> Rsvp.changeset(%{user_id: user_id, event_id: event_id})
    |> Repo.insert()
  end

  # Delete an RSVP (un-RSVP)
  def delete_rsvp(user_id, event_id) do
    rsvp = Repo.get_by(Rsvp, user_id: user_id, event_id: event_id)
    Repo.delete(rsvp)
  end

  # Count RSVPs for an event
  def count_rsvps(event_id) do
    Repo.aggregate(
      from(r in Rsvp, where: r.event_id == ^event_id),
      :count
    )
  end

end
