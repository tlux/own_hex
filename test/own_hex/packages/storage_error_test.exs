defmodule OwnHex.Packages.StorageErrorTest do
  use ExUnit.Case, async: true

  alias OwnHex.Packages.StorageError

  test "Exception.message/1" do
    assert Exception.message(%StorageError{path: "/foo/bar"}) ==
             "Failed to read from or write to package storage while accessing /foo/bar"
  end
end
