defmodule RedisApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RedisAppWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:redis_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RedisApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RedisApp.Finch},
      # Start a worker by calling: RedisApp.Worker.start_link(arg)
      # {RedisApp.Worker, arg},
      # Start to serve requests, typically the last entry
      RedisAppWeb.Endpoint,
      {Redix, name: :redix}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RedisApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RedisAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
