defmodule NeighborHub.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string

      timestamps() #when was user inserted and updates => it creates two extra columns => inserted_at and updated_at
      # id is default it is automatically created when we did create table
    end

    # this tells psql that no two users can have the same email
    create unique_index(:users, [:email])
  end
end
