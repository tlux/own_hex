defmodule OwnHex.Packages.PackageVersionTest do
  use ExUnit.Case, async: false

  alias OwnHex.Config
  alias OwnHex.Packages.PackageNotFoundError
  alias OwnHex.Packages.PackageVersion
  alias OwnHex.Packages.Specification

  @specification %Specification{
    name: "foo",
    version: Version.parse!("1.0.0")
  }

  describe "from_specification/1" do
    setup do
      File.mkdir_p!(Config.tarballs_dir())
      File.mkdir_p!(Config.docs_dir())

      on_exit(fn ->
        File.rm_rf!(Config.registry_dir())
        File.rm_rf!(Config.docs_dir())
      end)
    end

    test "tarball not found" do
      assert PackageVersion.from_specification(@specification) ==
               {:error,
                %PackageNotFoundError{
                  name: @specification.name,
                  version: @specification.version
                }}
    end

    test "no docs available" do
      File.cp!(
        "test/fixtures/archive-1.2.3.tar",
        Specification.tarball_path(@specification)
      )

      assert PackageVersion.from_specification(@specification) ==
               {:ok,
                %PackageVersion{
                  name: @specification.name,
                  version: @specification.version,
                  updated_at:
                    @specification
                    |> Specification.tarball_path()
                    |> File.stat!()
                    |> Map.fetch!(:mtime)
                    |> NaiveDateTime.from_erl!(),
                  docs?: false
                }}
    end

    test "docs available" do
      File.cp!(
        "test/fixtures/archive-1.2.3.tar",
        Specification.tarball_path(@specification)
      )

      File.mkdir_p!(Specification.docs_dir(@specification))

      assert {:ok, %PackageVersion{docs?: true}} =
               PackageVersion.from_specification(@specification)
    end
  end
end
