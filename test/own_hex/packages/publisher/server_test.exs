defmodule OwnHex.Packages.Publisher.ServerTest do
  use ExUnit.Case, async: true

  import Mox

  alias OwnHex.Packages.Publisher.Mock
  alias OwnHex.Packages.Publisher.Server
  alias OwnHex.Packages.Specification

  @specification Specification.new!("test", "1.2.3")
  @path "/path/to/test.tar"

  setup :set_mox_from_context
  setup :verify_on_exit!

  setup do
    server = start_supervised!(Server)
    allow(Mock, self(), server)
    :ok
  end

  test "public_package/2" do
    expect(Mock, :publish_package, fn @specification, @path ->
      :ok
    end)

    assert Server.publish_package(@specification, @path) == :ok
  end

  test "publish_docs/2" do
    expect(Mock, :publish_docs, fn @specification, @path ->
      :ok
    end)

    assert Server.publish_docs(@specification, @path) == :ok
  end
end
