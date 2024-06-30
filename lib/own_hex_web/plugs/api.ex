defmodule OwnHexWeb.Plugs.API do
  @moduledoc """
  A plug that provides a JSON API.
  """

  use Plug.Router

  import OwnHexWeb.Params
  import OwnHexWeb.Responses

  alias OwnHex.Packages
  alias OwnHex.Packages.PackageNotFoundError
  alias OwnHex.Packages.Specification

  plug :match

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    pass: ["*/*"]

  plug Accent.Plug.Response,
    default_case: Accent.Case.Camel,
    header: "x-keys",
    json_codec: Jason

  plug :dispatch

  get "/packages" do
    conn = fetch_query_params(conn)

    case Packages.list_packages(
           drop: param(conn, :drop, :int, 0),
           take: param(conn, :take, :int, 100),
           search: param(conn, :search, :string, nil),
           sort: param(conn, :sort, :string, nil)
         ) do
      {:ok, packages} -> data_json(conn, packages)
      {:error, _} -> error_json(conn, "Unable to list packages")
    end
  end

  get "/packages/:name" do
    case Packages.find_package(conn.params["name"]) do
      {:ok, package} -> data_json(conn, package)
      {:error, %PackageNotFoundError{}} -> error_status_json(conn, :not_found)
      {:error, _} -> error_json(conn, "Unable to find package")
    end
  end

  get "/packages/:name/:version" do
    with {:ok, specification} <- package_specification(conn),
         {:ok, package_version} <-
           Packages.find_package_version(specification) do
      data_json(conn, package_version)
    else
      {:error, %PackageNotFoundError{}} ->
        error_status_json(conn, :not_found)

      {:error, _} ->
        error_json(conn, "Unable to find package version")
    end
  end

  put "/packages/:name/:version" do
    with {:specification, {:ok, specification}} <-
           {:specification, package_specification(conn)},
         {:upload, {:ok, path}} <- {:upload, upload_path(conn, "tarball")},
         {:publish, :ok} <-
           {:publish, Packages.publish_package(specification, path)} do
      data_json(conn, :created, specification)
    else
      {:specification, {:error, error}} ->
        error_json(conn, :bad_request, Exception.message(error))

      {:upload, {:error, :missing, name}} ->
        error_json(conn, :bad_request, "Missing attribute: #{name}")

      {:upload, {:error, :invalid, name}} ->
        error_json(conn, :bad_request, "Invalid attribute: #{name}")

      {:publish, :conflict} ->
        error_json(conn, :conflict, "Package already exists")

      {:publish, _} ->
        error_json(conn, "Unable to publish package")
    end
  end

  put "/packages/:name/:version/docs" do
    with {:specification, {:ok, specification}} <-
           {:specification, package_specification(conn)},
         {:upload, {:ok, path}} <- {:upload, upload_path(conn, "tarball")},
         {:publish, :ok} <-
           {:publish, Packages.publish_docs(specification, path)} do
      data_json(conn, specification)
    else
      {:specification, {:error, error}} ->
        error_json(conn, :bad_request, Exception.message(error))

      {:upload, {:error, :missing, name}} ->
        error_json(conn, :bad_request, "Missing attribute: #{name}")

      {:upload, {:error, :invalid, name}} ->
        error_json(conn, :bad_request, "Invalid attribute: #{name}")

      {:publish, :not_found} ->
        error_json(conn, :not_found, "Package not found")

      {:publish, :conflict} ->
        error_json(conn, :conflict, "Docs already present for package")

      {:publish, _} ->
        error_json(conn, "Unable to publish docs")
    end
  end

  match _ do
    error_status_json(conn, :not_found)
  end

  defp upload_path(conn, name) do
    case Map.fetch(conn.body_params, name) do
      {:ok, %Plug.Upload{path: path}} -> {:ok, path}
      {:ok, _} -> {:error, :invalid, name}
      _ -> {:error, :missing, name}
    end
  end

  defp package_specification(conn) do
    Specification.new(conn.params["name"], conn.params["version"])
  end
end
