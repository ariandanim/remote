defmodule Remote.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RemoteWeb.Telemetry,
      Remote.Repo,
      {DNSCluster, query: Application.get_env(:remote, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Remote.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Remote.Finch},
      # Start a worker by calling: Remote.Worker.start_link(arg)
      # {Remote.Worker, arg},
      # Start to serve requests, typically the last entry
      RemoteWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Remote.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RemoteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
