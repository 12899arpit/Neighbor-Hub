defmodule NeighborHub.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string, null: false
      add :description, :text
      add :location, :string, null: false
      add :date, :naive_datetime, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      # ↑ foreign key — links every event to the user who created it
      # on_delete: :delete_all means if the user is deleted, their events are too

      timestamps()

    end

    create index(:events, [:user_id])
      # ↑ makes queries like "get all events by this user" fast
  end
end
