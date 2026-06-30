defmodule NeighborHub.Repo do
  use Ecto.Repo,
    otp_app: :neighbor_hub,
    adapter: Ecto.Adapters.Postgres
end
