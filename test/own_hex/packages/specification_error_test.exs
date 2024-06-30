defmodule OwnHex.Packages.SpecificationErrorTest do
  use ExUnit.Case, async: true

  alias OwnHex.Packages.SpecificationError

  describe "Exception.message/1" do
    test "missing attribute" do
      assert Exception.message(%SpecificationError{
               type: :missing,
               attribute: :name
             }) == "Missing attribute: name"
    end

    test "invalid attribute" do
      assert Exception.message(%SpecificationError{
               type: :invalid,
               attribute: :version
             }) == "Invalid attribute: version"
    end
  end
end
