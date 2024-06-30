defmodule OwnHexWeb.Plugs.DocsTest do
  use ExUnit.Case, async: false

  import Plug.{Conn, Test}

  alias OwnHex.Config
  alias OwnHexWeb.Plugs.Docs

  setup do
    copy_fixtures("lib", "0.1.0")
    copy_fixtures("lib", "0.2.0")

    on_exit(fn ->
      File.rm_rf!(Config.docs_dir())
    end)

    {:ok, opts: Docs.init([])}
  end

  test "found", %{opts: opts} do
    conn =
      :get
      |> conn("/lib/0.1.0/index.html")
      |> Docs.call(opts)

    assert conn.status == 200

    assert conn.resp_body ==
             File.read!(
               Path.join([Config.docs_dir(), "lib", "0.1.0", "index.html"])
             )
  end

  test "redirect to index", %{opts: opts} do
    conn =
      :get
      |> conn("/lib/0.1.0")
      |> Docs.call(opts)

    assert conn.status == 302
    assert conn.resp_body == "You are being redirected"
    assert get_resp_header(conn, "location") == ["/lib/0.1.0/index.html"]
  end

  test "redirect to most recent version", %{opts: opts} do
    conn =
      :get
      |> conn("/lib")
      |> Docs.call(opts)

    assert conn.status == 302
    assert conn.resp_body == "You are being redirected"
    assert get_resp_header(conn, "location") == ["/lib/0.2.0/index.html"]
  end

  test "lib not found", %{opts: opts} do
    conn =
      :get
      |> conn("/foo")
      |> Docs.call(opts)

    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end

  test "empty lib", %{opts: opts} do
    conn =
      :get
      |> conn("/empty_lib")
      |> Docs.call(opts)

    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end

  test "version not found", %{opts: opts} do
    conn =
      :get
      |> conn("/lib/0.3.0")
      |> Docs.call(opts)

    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end

  test "file not found and 404.html not available", %{opts: opts} do
    conn =
      :get
      |> conn("/lib/0.1.0/foo.html")
      |> Docs.call(opts)

    assert conn.status == 302
    assert get_resp_header(conn, "location") == ["/lib/0.1.0/404.html"]
  end

  test "redirect to 404.html when file not found", %{opts: opts} do
    File.rm!(Path.join([Config.docs_dir(), "lib", "0.1.0", "404.html"]))

    conn =
      :get
      |> conn("/lib/0.1.0/foo.html")
      |> Docs.call(opts)

    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end

  test "root not found", %{opts: opts} do
    conn =
      :get
      |> conn("/")
      |> Docs.call(opts)

    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end

  defp copy_fixtures(name, version) do
    dir = Path.join([Config.docs_dir(), name, version])
    File.mkdir_p!(dir)
    File.cp_r!("test/fixtures/doc", dir)
  end
end
