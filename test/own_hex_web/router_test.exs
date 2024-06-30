defmodule OwnHexWeb.RouterTest do
  use ExUnit.Case, async: false

  import Mox
  import Plug.{Conn, Test}

  alias OwnHex.Config
  alias OwnHex.Packages
  alias OwnHexWeb.Router

  setup :verify_on_exit!

  setup do
    username = "hex"
    password = "s3cret"
    basic_auth = Plug.BasicAuth.encode_basic_auth(username, password)

    on_exit(fn ->
      File.rm_rf!(Config.registry_dir())
      File.rm_rf!(Config.docs_dir())
    end)

    {:ok,
     opts: Router.init([]),
     basic_auth: basic_auth,
     username: username,
     password: password}
  end

  test "get static file", %{basic_auth: basic_auth, opts: opts} do
    File.mkdir_p!(Config.tarballs_dir())

    File.cp!(
      "test/fixtures/archive-1.2.3.tar",
      Path.join(Config.tarballs_dir(), "archive-1.2.3.tar")
    )

    conn =
      :get
      |> conn("/tarballs/archive-1.2.3.tar")
      |> put_req_header("authorization", basic_auth)
      |> Router.call(opts)

    assert conn.resp_body == File.read!("test/fixtures/archive-1.2.3.tar")
    assert conn.status == 200
  end

  test "unauthorized", %{opts: opts} do
    conn =
      :get
      |> conn("/")
      |> Router.call(opts)

    assert conn.resp_body == "Unauthorized"
    assert conn.status == 401
  end

  test "not found", %{basic_auth: basic_auth, opts: opts} do
    conn =
      :get
      |> conn("/")
      |> put_req_header("authorization", basic_auth)
      |> Router.call(opts)

    assert conn.resp_body == "Not Found"
    assert conn.status == 404
  end

  test "delegate /api requests to API plug", %{
    basic_auth: basic_auth,
    opts: opts
  } do
    expect(Packages.Mock, :list_packages, fn _ -> {:ok, []} end)

    conn =
      :get
      |> conn("/api/packages")
      |> put_req_header("authorization", basic_auth)
      |> Router.call(opts)

    assert conn.status == 200
  end

  test "delegate /docs requests for Docs plug", %{
    basic_auth: basic_auth,
    opts: opts
  } do
    docs_dir =
      Packages.Specification.docs_dir(
        Packages.Specification.new!("test", "1.2.3")
      )

    File.mkdir_p!(docs_dir)

    file_content = "file content"

    docs_dir
    |> Path.join("file.html")
    |> File.write!(file_content)

    conn =
      :get
      |> conn("/docs/test/1.2.3/file.html")
      |> put_req_header("authorization", basic_auth)
      |> Router.call(opts)

    assert conn.status == 200
    assert conn.resp_body == file_content
  end
end
