defmodule OwnHex.Registry.BuildErrorTest do
  use ExUnit.Case, async: true

  alias OwnHex.Registry.BuildError

  test "Exception.message/1" do
    assert Exception.message(%BuildError{reason: "foo"}) ==
             "Failed to build registry: foo"
  end
end
