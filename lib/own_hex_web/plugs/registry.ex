defmodule OwnHexWeb.Plugs.Registry do
  @moduledoc """
  A plug to serve the contents from the registry dir.
  """

  @behaviour Plug

  import OwnHexWeb.Responses

  alias OwnHex.Config

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    opts = Plug.Static.init(at: "/", from: Config.registry_dir())

    case Plug.Static.call(conn, opts) do
      %{halted: true} = conn -> conn
      conn -> not_found(conn)
    end
  end
end
