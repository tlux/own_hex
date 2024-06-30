defmodule OwnHex.Packages.PackageNotFoundErrorTest do
  use ExUnit.Case, async: true

  alias OwnHex.Packages.PackageNotFoundError

  describe "Exception.message/1" do
    test "name only" do
      assert Exception.message(%PackageNotFoundError{name: "foo"}) ==
               "Package foo not found"
    end

    test "name and version" do
      assert Exception.message(%PackageNotFoundError{
               name: "foo",
               version: Version.parse!("1.0.0")
             }) == "Package foo@1.0.0 not found"
    end
  end
end
