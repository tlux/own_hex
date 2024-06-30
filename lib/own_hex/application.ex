defmodule OwnHex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  alias OwnHex.Config

  @impl true
  def start(_type, _args) do
    Logger.info("Starting server listening on port #{Config.port()}")

    if is_nil(Config.auth()) && System.get_env("NOAUTH") != "true" do
      Logger.warning(
        "Basic authentication is disabled. " <>
          "Set NOAUTH=true if you want to disable this warning."
      )
    end

    children = [
      {Plug.Cowboy,
       scheme: :http,
       plug: {OwnHexWeb.Router, []},
       options: [port: Config.port()]},
      OwnHex.Packages.Publisher.Server
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: OwnHex.Supervisor
    )
  end
end
