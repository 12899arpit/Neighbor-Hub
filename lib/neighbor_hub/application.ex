defmodule NeighborHub.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NeighborHubWeb.Telemetry,
      NeighborHub.Repo,
      {DNSCluster, query: Application.get_env(:neighbor_hub, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NeighborHub.PubSub},
      # Start a worker by calling: NeighborHub.Worker.start_link(arg)
      # {NeighborHub.Worker, arg},
      # Start to serve requests, typically the last entry
      NeighborHubWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NeighborHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NeighborHubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
