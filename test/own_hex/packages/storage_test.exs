defmodule OwnHex.Packages.StorageTest do
  use ExUnit.Case, async: false

  import Mox

  alias OwnHex.Config
  alias OwnHex.Packages.Package
  alias OwnHex.Packages.PackageNotFoundError
  alias OwnHex.Packages.PackageVersion
  alias OwnHex.Packages.Publisher.Mock, as: PublisherMock
  alias OwnHex.Packages.Specification
  alias OwnHex.Packages.Storage

  setup :verify_on_exit!

  @package_name "awesome_package"
  @archive_path "test/fixtures/archive-1.2.3.tar"

  setup do
    File.mkdir_p!(Config.tarballs_dir())
    File.mkdir_p!(Config.docs_dir())

    on_exit(fn ->
      File.rm_rf!(Config.registry_dir())
      File.rm_rf!(Config.docs_dir())
    end)
  end

  describe "list_packages/0" do
    setup do
      path_1 =
        Specification.tarball_path(Specification.new!(@package_name, "1.0.0"))

      File.cp!(@archive_path, path_1)
      File.touch!(path_1, {{2017, 1, 1}, {0, 0, 0}})

      path_2 =
        Specification.tarball_path(Specification.new!(@package_name, "1.2.3"))

      File.cp!(@archive_path, path_2)
      File.touch!(path_2, {{2023, 1, 2}, {12, 0, 0}})

      path_3 = Specification.tarball_path(Specification.new!("foo", "2.0.0"))

      File.cp!(@archive_path, path_3)
      File.touch!(path_3, {{2020, 1, 2}, {12, 0, 0}})

      File.mkdir_p!(Path.join([Config.docs_dir(), @package_name, "1.0.0"]))

      :ok
    end

    test "sort by name" do
      assert Storage.list_packages() ==
               {:ok,
                [
                  %Package{
                    name: @package_name,
                    versions: [
                      PackageVersion.from_specification!(
                        Specification.new!(@package_name, "1.2.3")
                      ),
                      PackageVersion.from_specification!(
                        Specification.new!(@package_name, "1.0.0")
                      )
                    ],
                    latest_version:
                      PackageVersion.from_specification!(
                        Specification.new!(@package_name, "1.2.3")
                      )
                  },
                  %Package{
                    name: "foo",
                    versions: [
                      PackageVersion.from_specification!(
                        Specification.new!("foo", "2.0.0")
                      )
                    ],
                    latest_version:
                      PackageVersion.from_specification!(
                        Specification.new!("foo", "2.0.0")
                      )
                  }
                ]}
    end

    test "sort by recent first" do
      assert {:ok,
              [
                %Package{name: @package_name},
                %Package{name: "foo"}
              ]} = Storage.list_packages(sort: "recent")
    end

    test "search" do
      assert {:ok, [%Package{name: @package_name}]} =
               Storage.list_packages(search: "awes")

      assert {:ok, [%Package{name: "foo"}]} =
               Storage.list_packages(search: "fo")

      assert {:ok, []} = Storage.list_packages(search: "bar")
    end

    test "take" do
      assert {:ok, [%Package{name: @package_name}]} =
               Storage.list_packages(take: 1)

      assert {:ok, []} = Storage.list_packages(take: 0)
    end

    test "drop" do
      assert {:ok, [%Package{name: "foo"}]} = Storage.list_packages(drop: 1)

      assert {:ok, []} = Storage.list_packages(drop: 2)
    end

    test "empty list when directory does not exist" do
      File.rm_rf!(Config.registry_dir())

      assert Storage.list_packages() == {:ok, []}
    end
  end

  describe "find_package/1" do
    test "success" do
      File.cp!(
        @archive_path,
        Specification.tarball_path(Specification.new!(@package_name, "1.0.0"))
      )

      version =
        PackageVersion.from_specification!(
          Specification.new!(@package_name, "1.0.0")
        )

      assert Storage.find_package(@package_name) ==
               {:ok,
                %Package{
                  name: @package_name,
                  versions: [version],
                  latest_version: version
                }}
    end

    test "package not found" do
      assert Storage.find_package(@package_name) ==
               {:error, %PackageNotFoundError{name: @package_name}}
    end
  end

  describe "find_package_version/1" do
    @specification Specification.new!(@package_name, "1.0.0")

    test "success" do
      File.cp!(@archive_path, Specification.tarball_path(@specification))

      assert Storage.find_package_version(@specification) ==
               {:ok, PackageVersion.from_specification!(@specification)}
    end

    test "package not found" do
      assert Storage.find_package_version(@specification) ==
               {:error, %PackageNotFoundError{name: @specification.name}}
    end

    test "package version not found" do
      File.cp!(
        @archive_path,
        Specification.tarball_path(%{
          @specification
          | version: Version.parse!("2.0.0")
        })
      )

      assert Storage.find_package_version(@specification) ==
               {:error,
                %PackageNotFoundError{
                  name: @specification.name,
                  version: @specification.version
                }}
    end
  end

  describe "package_version_exists?/1" do
    @specification Specification.new!(@package_name, "1.0.0")

    test "success" do
      File.cp!(@archive_path, Specification.tarball_path(@specification))

      assert Storage.package_version_exists?(@specification) == true
    end

    test "package not found" do
      assert Storage.package_version_exists?(@specification) == false
    end

    test "package version not found" do
      File.cp!(
        @archive_path,
        Specification.tarball_path(%{
          @specification
          | version: Version.parse!("2.0.0")
        })
      )

      assert Storage.package_version_exists?(@specification) == false
    end
  end

  describe "publish_package/2" do
    test "delegate to publisher" do
      expect(PublisherMock, :publish_package, fn @package_name, @archive_path ->
        :ok
      end)

      assert :ok = Storage.publish_package(@package_name, @archive_path)
    end
  end

  describe "publish_docs/2" do
    test "delegate to publisher" do
      expect(PublisherMock, :publish_docs, fn @package_name, @archive_path ->
        :ok
      end)

      assert :ok = Storage.publish_docs(@package_name, @archive_path)
    end
  end
end
