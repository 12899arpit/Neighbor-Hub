defmodule NeighborHubWeb.EventLive do
  use NeighborHubWeb, :live_view

  alias NeighborHub.Events

  # mount/3 runs once when the user first visits the page
  # it loads all the data the template needs
  def mount(%{"id" => id}, session, socket) do
    event = Events.get_event!(id)
    user_id = session["user_id"]
    rsvp_count = Events.count_rsvps(event.id)
    has_rsvp  = if user_id, do: Events.rsvp_exists?(user_id, event.id), else: false

    {:ok,
     socket
     |> assign(:event, event)
     |> assign(:user_id, user_id)
     |> assign(:rsvp_count, rsvp_count)
     |> assign(:has_rsvp, has_rsvp)}
     # assign() puts data on the socket — like conn.assigns but for LiveView
  end

  # handle_event/3 runs when the user does something on the page
  # "toggle_rsvp" is the event name we'll fire from the template
  def handle_event("toggle_rsvp", _params, socket) do
    user_id  = socket.assigns.user_id
    event_id = socket.assigns.event.id

    if socket.assigns.has_rsvp do
      Events.delete_rsvp(user_id, event_id)
    else
      Events.create_rsvp(user_id, event_id)
    end

    # recalculate and update the socket assigns
    new_count    = Events.count_rsvps(event_id)
    new_has_rsvp = Events.rsvp_exists?(user_id, event_id)

    {:noreply,
     socket
     |> assign(:rsvp_count, new_count)
     |> assign(:has_rsvp, new_has_rsvp)}
     # {:noreply, socket} means: update the page with new assigns
     # Phoenix calculates the diff and sends only what changed to the browser
  end

end
