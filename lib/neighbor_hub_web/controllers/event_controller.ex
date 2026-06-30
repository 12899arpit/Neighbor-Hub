defmodule NeighborHubWeb.EventController do

  use NeighborHubWeb, :controller

  alias NeighborHub.Events
  alias NeighborHub.Events.Event

    # GET /events — list all events
  def index(conn, params) do
    page = String.to_integer(params["page"] || "1")
    result = Events.list_events(page)
    render(conn, :index,
    events: result.events,
    page: result.page,
    total_pages: result.total_pages,
    has_next: result.has_next,
    has_prev: result.has_prev)
  end

    # GET /events/:id — show one event
  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render(conn, :show, event: event)
  end

   # GET /events/new — show the create form
   def new(conn, _params) do
    if conn.assigns.current_user do
      changeset = Events.change_event(%Event{})
      render(conn, :new, changeset: changeset)

    else
      conn
      |> put_flash(:error, "You must be logged in to create an event.")
      |> redirect(to: ~p"/login")
    end

   end

   # POST /events — save the new event
  def create(conn, %{"event" => event_params}) do
    # attach the current user's id to the event params
    event_params = Map.put(event_params, "user_id", conn.assigns.current_user.id)

    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully!")
        |> redirect(to: ~p"/events/#{event.id}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

    # DELETE /events/:id — delete an event
  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)

    # make sure only the creator can delete their event
    if event.user_id == conn.assigns.current_user.id do
      Events.delete_event(event)
      conn
      |> put_flash(:info, "Event deleted successfully!")
      |> redirect(to: ~p"/events")

    else
      conn
      |> put_flash(:error, "You can't delete someone else's event.")
      |> redirect(to: ~p"/events/#{id}")
    end
  end

end
