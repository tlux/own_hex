defmodule OwnHex.Packages.SpecificationTest do
  use ExUnit.Case, async: true

  alias OwnHex.Config
  alias OwnHex.Packages.Specification
  alias OwnHex.Packages.SpecificationError

  describe "new/2" do
    test "creates a specification with name and version string" do
      assert Specification.new("archive", "1.0.0") ==
               {:ok,
                %Specification{
                  name: "archive",
                  version: Version.parse!("1.0.0")
                }}
    end

    test "creates a specification with name and version struct" do
      version = Version.parse!("1.0.0")

      assert Specification.new("archive", version) ==
               {:ok,
                %Specification{
                  name: "archive",
                  version: version
                }}
    end

    test "error when name is missing" do
      error = {:error, %SpecificationError{type: :missing, attribute: :name}}

      assert Specification.new(nil, "1.0.0") == error
      assert Specification.new("", "1.0.0") == error
    end

    test "error when name has invalid format" do
      Enum.each(["foo bar", "foo-bar", "FooBar", :foo], fn name ->
        assert Specification.new(name, "1.0.0") ==
                 {:error, %SpecificationError{type: :invalid, attribute: :name}}
      end)
    end

    test "error when version is missing" do
      error = {:error, %SpecificationError{type: :missing, attribute: :version}}

      assert Specification.new("archive", nil) == error
      assert Specification.new("archive", "") == error
    end

    test "error when version has invalid format" do
      Enum.each(["foo", "1", "1.0", :foo], fn version ->
        assert Specification.new("archive", version) ==
                 {:error,
                  %SpecificationError{type: :invalid, attribute: :version}}
      end)
    end
  end

  describe "new!/2" do
    test "success" do
      assert Specification.new!("archive", "1.0.0") ==
               %Specification{
                 name: "archive",
                 version: Version.parse!("1.0.0")
               }
    end

    test "error" do
      assert_raise SpecificationError, "Missing attribute: version", fn ->
        Specification.new!("archive", nil)
      end
    end
  end

  describe "from_tarball/1" do
    test "creates a specification from a tarball filename" do
      assert Specification.from_tarball("archive-1.0.0.tar") ==
               {:ok, Specification.new!("archive", "1.0.0")}

      assert Specification.from_tarball("foo_bar-1.2.3-rc1.tar") ==
               {:ok, Specification.new!("foo_bar", "1.2.3-rc1")}
    end

    test "error when filename is invalid" do
      Enum.each(
        ["foo", "1.0.0", "foo-1.0.0.tar.gz"],
        fn filename ->
          assert Specification.from_tarball(filename) == :error
        end
      )
    end
  end

  describe "docs_dir/1" do
    test "gets the docs directory for the specification" do
      assert Specification.docs_dir(Specification.new!("archive", "1.0.0")) ==
               Path.join([Config.docs_dir(), "archive", "1.0.0"])
    end
  end

  describe "tarball/1" do
    test "gets the tarball filename for the specification" do
      assert Specification.tarball(Specification.new!("archive", "1.0.0")) ==
               "archive-1.0.0.tar"
    end
  end

  describe "tarball_path/1" do
    test "gets the tarball path for the specification" do
      assert Specification.tarball_path(Specification.new!("archive", "1.0.0")) ==
               Path.join(Config.tarballs_dir(), "archive-1.0.0.tar")
    end
  end

  describe "compare/1" do
    test "compares versions" do
      assert Specification.compare(
               %Specification{
                 name: "archive",
                 version: Version.parse!("1.0.0")
               },
               %Specification{name: "archive", version: Version.parse!("1.0.0")}
             ) == :eq

      assert Specification.compare(
               %Specification{
                 name: "archive",
                 version: Version.parse!("1.0.0")
               },
               %Specification{name: "other", version: Version.parse!("1.0.0")}
             ) == :lt

      assert Specification.compare(
               %Specification{name: "other", version: Version.parse!("1.0.0")},
               %Specification{name: "archive", version: Version.parse!("1.0.0")}
             ) == :gt

      assert Specification.compare(
               %Specification{
                 name: "archive",
                 version: Version.parse!("1.0.0-rc1")
               },
               %Specification{name: "archive", version: Version.parse!("1.0.0")}
             ) == :lt

      assert Specification.compare(
               %Specification{
                 name: "archive",
                 version: Version.parse!("0.9.0")
               },
               %Specification{name: "archive", version: Version.parse!("1.0.0")}
             ) == :lt

      assert Specification.compare(
               %Specification{
                 name: "archive",
                 version: Version.parse!("1.0.1")
               },
               %Specification{name: "archive", version: Version.parse!("1.0.0")}
             ) == :gt
    end
  end
end
