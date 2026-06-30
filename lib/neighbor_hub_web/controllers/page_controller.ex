defmodule NeighborHubWeb.PageController do
  use NeighborHubWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
