defmodule OwnHexWeb.Plugs.Docs do
  @moduledoc """
  A plug to serve the contents from the docs dir.
  """

  @behaviour Plug

  import OwnHexWeb.Responses

  alias OwnHex.Config

  @index_file "index.html"
  @not_found_file "404.html"

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%{path_info: [lib]} = conn, _opts) do
    case File.ls(Path.join(Config.docs_dir(), lib)) do
      {:ok, []} ->
        not_found(conn)

      {:ok, versions} ->
        recent_version = versions |> Enum.sort(:desc) |> hd()
        path_info_with_index = conn.path_info ++ [recent_version, @index_file]
        redirect(conn, build_path(conn, path_info_with_index))

      {:error, _} ->
        not_found(conn)
    end
  end

  def call(%{path_info: [_, _]} = conn, _opts) do
    path_info_with_index = conn.path_info ++ [@index_file]

    if File.exists?(Path.join([Config.docs_dir() | path_info_with_index])) do
      redirect(conn, build_path(conn, path_info_with_index))
    else
      not_found(conn)
    end
  end

  def call(%{path_info: [name, version | _]} = conn, _opts) do
    opts = Plug.Static.init(at: "/", from: Config.docs_dir())

    case Plug.Static.call(conn, opts) do
      %{halted: true} = conn ->
        conn

      conn ->
        not_found_path =
          Path.join([Config.docs_dir(), name, version, @not_found_file])

        if File.exists?(not_found_path) do
          redirect(conn, build_path(conn, [name, version, @not_found_file]))
        else
          not_found(conn)
        end
    end
  end

  def call(conn, _opts), do: not_found(conn)

  defp build_path(conn, path_info) when is_list(path_info) do
    current_rel_path = Enum.join(conn.path_info, "/")
    base_path = String.trim_trailing(conn.request_path, current_rel_path)
    rel_path = Enum.join(path_info, "/")
    base_path <> rel_path
  end
end
