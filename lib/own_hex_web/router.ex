defmodule OwnHexWeb.Router do
  @moduledoc """
  The app router.
  """

  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger, otp_app: :own_hex
  end

  alias OwnHex.Config
  alias OwnHexWeb.Plugs

  plug Plug.Logger, log: :info
  plug :match
  plug :auth
  plug :dispatch

  forward "/api", to: Plugs.API
  forward "/docs", to: Plugs.Docs
  forward "/", to: Plugs.Registry

  defp auth(conn, _opts) do
    case Config.auth() do
      nil -> conn
      auth -> Plug.BasicAuth.basic_auth(conn, auth)
    end
  end
end
