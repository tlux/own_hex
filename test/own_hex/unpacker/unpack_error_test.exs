defmodule OwnHex.Unpacker.UnpackErrorTest do
  use ExUnit.Case, async: true

  alias OwnHex.Unpacker.UnpackError

  test "Exception.message/1" do
    assert Exception.message(%UnpackError{reason: :eof}) ==
             "Error unpacking archive: :eof"
  end
end
