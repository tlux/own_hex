defmodule OwnHex.Unpacker.InvalidArchiveErrorTest do
  use ExUnit.Case, async: true

  alias OwnHex.Unpacker.InvalidArchiveError

  test "Exception.message/1" do
    assert Exception.message(%InvalidArchiveError{filename: "foo.zip"}) ==
             "Invalid archive: foo.zip"
  end
end
