defmodule OwnHexWeb.Plugs.APITest do
  use ExUnit.Case, async: true

  import Mox
  import Plug.Test
  import OwnHex.JsonAssertions

  alias OwnHex.Packages
  alias OwnHex.Packages.Package
  alias OwnHex.Packages.PackageVersion
  alias OwnHex.Packages.Specification
  alias OwnHex.Packages.StorageError
  alias OwnHexWeb.Plugs.API

  setup :verify_on_exit!

  setup do
    {:ok, opts: API.init([])}
  end

  @package %Package{
    name: "test",
    latest_version: %PackageVersion{
      name: "test",
      version: Version.parse!("1.2.3"),
      docs?: false,
      updated_at: ~N[2000-01-02 00:00:00]
    },
    versions: [
      %PackageVersion{
        name: "test",
        version: Version.parse!("1.0.0"),
        docs?: true,
        updated_at: ~N[2000-01-01 00:00:00]
      },
      %PackageVersion{
        name: "test",
        version: Version.parse!("1.2.3"),
        docs?: false,
        updated_at: ~N[2000-01-02 00:00:00]
      }
    ]
  }

  @path "test/fixtures/archive-1.2.3.tar"

  @specification Specification.new!("test", "1.2.3")

  describe "GET /packages" do
    test "success", %{opts: opts} do
      expect(Packages.Mock, :list_packages, fn [
                                                 drop: 0,
                                                 take: 100,
                                                 search: nil,
                                                 sort: nil
                                               ] ->
        {:ok, [@package]}
      end)

      conn =
        :get
        |> conn("/packages")
        |> API.call(opts)

      assert conn.status == 200

      assert_json_equal conn.resp_body, """
        {
          "data": [
            {
              "name": "test",
              "latestVersion": {
                "name": "test",
                "version": "1.2.3",
                "hasDocs": false,
                "updatedAt": "2000-01-02T00:00:00"
              },
              "versions": [
                {
                  "name": "test",
                  "version": "1.2.3",
                  "hasDocs": false,
                  "updatedAt": "2000-01-02T00:00:00"
                },
                {
                  "name": "test",
                  "version": "1.0.0",
                  "hasDocs": true,
                  "updatedAt": "2000-01-01T00:00:00"
                }
              ]
            }
          ]
        }
      """
    end

    test "pass params", %{opts: opts} do
      params = [drop: 1, take: 2, search: "test", sort: "recent"]

      expect(Packages.Mock, :list_packages, fn ^params ->
        {:ok, []}
      end)

      conn =
        :get
        |> conn("/packages", params)
        |> API.call(opts)

      assert conn.status == 200
    end

    test "error", %{opts: opts} do
      expect(Packages.Mock, :list_packages, fn _ ->
        {:error, %StorageError{path: "/foo/bar"}}
      end)

      conn =
        :get
        |> conn("/packages")
        |> API.call(opts)

      assert conn.status == 500

      assert_json_equal conn.resp_body, """
        {
          "error": "Unable to list packages"
        }
      """
    end
  end

  describe "GET /packages/:name" do
    test "success", %{opts: opts} do
      expect(Packages.Mock, :find_package, fn "test" ->
        {:ok, @package}
      end)

      conn =
        :get
        |> conn("/packages/test")
        |> API.call(opts)

      assert conn.status == 200

      assert_json_equal conn.resp_body, """
        {
          "data": {
            "name": "test",
            "latestVersion": {
              "name": "test",
              "version": "1.2.3",
              "hasDocs": false,
              "updatedAt": "2000-01-02T00:00:00"
            },
            "versions": [
              {
                "name": "test",
                "version": "1.2.3",
                "hasDocs": false,
                "updatedAt": "2000-01-02T00:00:00"
              },
              {
                "name": "test",
                "version": "1.0.0",
                "hasDocs": true,
                "updatedAt": "2000-01-01T00:00:00"
              }
            ]
          }
        }
      """
    end

    test "not found", %{opts: opts} do
      expect(Packages.Mock, :find_package, fn "test" ->
        {:error, %Packages.PackageNotFoundError{name: "test"}}
      end)

      conn =
        :get
        |> conn("/packages/test")
        |> API.call(opts)

      assert conn.status == 404

      assert_json_equal conn.resp_body, """
        {
          "error": "Not Found"
        }
      """
    end

    test "error", %{opts: opts} do
      expect(Packages.Mock, :find_package, fn "test" ->
        {:error, %StorageError{path: "/foo/bar"}}
      end)

      conn =
        :get
        |> conn("/packages/test")
        |> API.call(opts)

      assert conn.status == 500

      assert_json_equal conn.resp_body, """
        {
          "error": "Unable to find package"
        }
      """
    end
  end

  describe "GET /packages/:name/:version" do
    @version Version.parse!("1.2.3")

    test "success", %{opts: opts} do
      expect(Packages.Mock, :find_package_version, fn @specification ->
        {:ok, @package}
      end)

      conn =
        :get
        |> conn("/packages/test/1.2.3")
        |> API.call(opts)

      assert conn.status == 200

      assert_json_equal conn.resp_body, """
        {
          "data": {
            "name": "test",
            "latestVersion": {
              "name": "test",
              "version": "1.2.3",
              "hasDocs": false,
              "updatedAt": "2000-01-02T00:00:00"
            },
            "versions": [
              {
                "name": "test",
                "version": "1.2.3",
                "hasDocs": false,
                "updatedAt": "2000-01-02T00:00:00"
              },
              {
                "name": "test",
                "version": "1.0.0",
                "hasDocs": true,
                "updatedAt": "2000-01-01T00:00:00"
              }
            ]
          }
        }
      """
    end

    test "not found", %{opts: opts} do
      expect(Packages.Mock, :find_package_version, fn @specification ->
        {:error,
         %Packages.PackageNotFoundError{name: "test", version: @version}}
      end)

      conn =
        :get
        |> conn("/packages/test/1.2.3")
        |> API.call(opts)

      assert conn.status == 404

      assert_json_equal conn.resp_body, """
        {
          "error": "Not Found"
        }
      """
    end

    test "error", %{opts: opts} do
      expect(Packages.Mock, :find_package_version, fn @specification ->
        {:error, %StorageError{path: "/foo/bar"}}
      end)

      conn =
        :get
        |> conn("/packages/test/1.2.3")
        |> API.call(opts)

      assert conn.status == 500

      assert_json_equal conn.resp_body, """
        {
          "error": "Unable to find package version"
        }
      """
    end
  end

  describe "PUT /packages/:name/:version" do
    test "success", %{opts: opts} do
      expect(Packages.Mock, :publish_package, fn @specification, @path ->
        :ok
      end)

      conn =
        :put
        |> conn("/packages/test/1.2.3", tarball: upload(@path))
        |> API.call(opts)

      assert conn.status == 201

      assert_json_equal conn.resp_body, """
        {
          "data": {
            "name": "test",
            "version": "1.2.3"
          }
        }
      """
    end

    test "invalid name", %{opts: opts} do
      conn =
        :put
        |> conn("/packages/foo bar/1.2.3")
        |> API.call(opts)

      assert conn.status == 400

      assert_json_equal conn.resp_body, """
        {
          "error": "Invalid attribute: name"
        }
      """
    end

    test "invalid version", %{opts: opts} do
      conn =
        :put
        |> conn("/packages/test/foo")
        |> API.call(opts)

      assert conn.status == 400

      assert_json_equal conn.resp_body, """
        {
          "error": "Invalid attribute: version"
        }
      """
    end

    test "missing tarball", %{opts: opts} do
      conn =
        :put
        |> conn("/packages/test/1.2.3")
        |> API.call(opts)

      assert conn.status == 400

      assert_json_equal conn.resp_body, """
        {
          "error": "Missing attribute: tarball"
        }
      """
    end

    test "invalid tarball", %{opts: opts} do
      conn =
        :put
        |> conn("/packages/test/1.2.3", tarball: "foo")
        |> API.call(opts)

      assert conn.status == 400

      assert_json_equal conn.resp_body, """
        {
          "error": "Invalid attribute: tarball"
        }
      """
    end

    test "conflict error", %{opts: opts} do
      expect(Packages.Mock, :publish_package, fn @specification, @path ->
        :conflict
      end)

      conn =
        :put
        |> conn("/packages/test/1.2.3", tarball: upload(@path))
        |> API.call(opts)

      assert conn.status == 409

      assert_json_equal conn.resp_body, """
        {
          "error": "Package already exists"
        }
      """
    end

    test "publication error", %{opts: opts} do
      expect(Packages.Mock, :publish_package, fn @specification, @path ->
        {:error, %StorageError{path: "/foo/bar"}}
      end)

      conn =
        :put
        |> conn("/packages/test/1.2.3", tarball: upload(@path))
        |> API.call(opts)

      assert conn.status == 500

      assert_json_equal conn.resp_body, """
        {
          "error": "Unable to publish package"
        }
      """
    end
  end

  describe "PUT /packages/:name/:version/docs" do
    test "success", %{opts: opts} do
      expect(Packages.Mock, :publish_docs, fn @specification, @path ->
        :ok
      end)

      conn =
        :put
        |> conn("/packages/test/1.2.3/docs", tarball: upload(@path))
        |> API.call(opts)

      assert conn.status == 200

      assert_json_equal conn.resp_body, """
        {
          "data": {
            "name": "test",
            "version": "1.2.3"
          }
        }
      """
    end

    test "invalid name", %{opts: opts} do
      conn =
        :put
        |> conn("/packages/foo bar/1.2.3/docs")
        |> API.call(opts)

      assert conn.status == 400

      assert_json_equal conn.resp_body, """
        {
          "error": "Invalid attribute: name"
        }
      """
    end

    test "invalid version", %{opts: opts} do
      conn =
        :put
        |> conn("/packages/test/foo/docs")
        |> API.call(opts)

      assert conn.status == 400

      assert_json_equal conn.resp_body, """
        {
          "error": "Invalid attribute: version"
        }
      """
    end

    test "missing tarball", %{opts: opts} do
      conn =
        :put
        |> conn("/packages/test/1.2.3/docs")
        |> API.call(opts)

      assert conn.status == 400

      assert_json_equal conn.resp_body, """
        {
          "error": "Missing attribute: tarball"
        }
      """
    end

    test "invalid tarball", %{opts: opts} do
      conn =
        :put
        |> conn("/packages/test/1.2.3/docs", tarball: "foo")
        |> API.call(opts)

      assert conn.status == 400

      assert_json_equal conn.resp_body, """
        {
          "error": "Invalid attribute: tarball"
        }
      """
    end

    test "conflict error", %{opts: opts} do
      expect(Packages.Mock, :publish_docs, fn @specification, @path ->
        :conflict
      end)

      conn =
        :put
        |> conn("/packages/test/1.2.3/docs", tarball: upload(@path))
        |> API.call(opts)

      assert conn.status == 409

      assert_json_equal conn.resp_body, """
        {
          "error": "Docs already present for package"
        }
      """
    end

    test "package not found", %{opts: opts} do
      expect(Packages.Mock, :publish_docs, fn @specification, @path ->
        :not_found
      end)

      conn =
        :put
        |> conn("/packages/test/1.2.3/docs", tarball: upload(@path))
        |> API.call(opts)

      assert conn.status == 404

      assert_json_equal conn.resp_body, """
        {
          "error": "Package not found"
        }
      """
    end

    test "publication error", %{opts: opts} do
      expect(Packages.Mock, :publish_docs, fn @specification, @path ->
        {:error, %StorageError{path: "/foo/bar"}}
      end)

      conn =
        :put
        |> conn("/packages/test/1.2.3/docs", tarball: upload(@path))
        |> API.call(opts)

      assert conn.status == 500

      assert_json_equal conn.resp_body, """
        {
          "error": "Unable to publish docs"
        }
      """
    end
  end

  test "not found", %{opts: opts} do
    conn = :get |> conn("/foobar") |> API.call(opts)

    assert conn.status == 404

    assert_json_equal conn.resp_body, """
      {
        "error": "Not Found"
      }
    """
  end

  defp upload(path) do
    %Plug.Upload{
      path: path,
      filename: Path.basename(path),
      content_type: "application/octet-stream"
    }
  end
end
