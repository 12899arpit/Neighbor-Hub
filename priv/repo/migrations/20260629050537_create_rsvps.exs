defmodule NeighborHub.Repo.Migrations.CreateRsvps do
  use Ecto.Migration

  def change do
    create table(:rsvps) do
      add :user_id,  references(:users, on_delete: :delete_all), null: false
      add :event_id, references(:events, on_delete: :delete_all), null: false

      timestamps()
    end

     # one user can only RSVP once per event
    create unique_index(:rsvps, [:user_id, :event_id])
  end
end
