defmodule NeighborHubWeb.ApiEventController do
  use NeighborHubWeb, :controller

  alias NeighborHub.Events
  alias NeighborHub.Events.Event


  def index(conn, _paramas) do
    events = Events.list_events()

    json(conn, %{
      events: Enum.map(events, &format_event/1)
    })
  end


  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    json(conn, %{
      event: format_event(event)
    })
  end


  def create(conn, %{"event" => event_params}) do
    # verify the token sent in the Authorization header

    case get_user_from_token(conn) do
      {:ok, user_id} ->
        event_params = Map.put(event_params, "user_id", user_id)



        case Events.create_event(event_params) do
          {:ok, event} ->
            event = Events.get_event!(event.id)
            conn
            |> put_status(:created)
            |> json(%{
              event: format_event(event)
            })


          {:error, changeset} ->
            conn
            |> put_status("unprocessable_entity")
            |> json(%{
              errros: format_errors(changeset)
            })

        end

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          error: "Invalid or missing token"
        })
    end

  end

  #PRIVATE HELPERS

  defp get_user_from_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        Phoenix.Token.verify(conn, "user_auth", token, max_age: 86400)
        # max_age: 86400 = token expires after 24 hours (in seconds)

      _ ->
        {:error, :missing_token}
    end
  end

  defp format_event(event) do
    %{
      id: event.id,
      title: event.title,
      description: event.description,
      location:    event.location,
      date:        event.date,
      created_by:  event.user.name,
      inserted_at: event.inserted_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn{key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

end
