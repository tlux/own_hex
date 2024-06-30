defmodule OwnHex.Packages.PackageTest do
  use ExUnit.Case, async: true

  import OwnHex.JsonAssertions

  alias OwnHex.Packages.Package
  alias OwnHex.Packages.PackageVersion

  @datetime NaiveDateTime.from_erl!({{2020, 1, 1}, {0, 0, 0}})

  describe "new/1" do
    test "creates a new package struct" do
      package = Package.new("test")

      assert package.name == "test"
      assert package.versions == []
      assert package.latest_version == nil
    end
  end

  describe "compare/2" do
    @package Package.new("test")
    @other_package Package.new("my_awesome_package")

    test "equality" do
      assert Package.compare(@package, @package) == :eq
    end

    test "less than" do
      assert Package.compare(@package, @other_package) == :gt
    end

    test "greater than" do
      assert Package.compare(@other_package, @package) == :lt
    end
  end

  describe "versions/1" do
    test "sorts versions with most recent first" do
      version_1_0_0 = %PackageVersion{
        name: "test",
        version: Version.parse!("1.0.0"),
        updated_at: @datetime
      }

      version_1_2_5 = %PackageVersion{
        name: "test",
        version: Version.parse!("1.2.5"),
        updated_at: @datetime
      }

      version_2_0_0 = %PackageVersion{
        name: "test",
        version: Version.parse!("2.0.0"),
        updated_at: @datetime
      }

      package =
        "test"
        |> Package.new()
        |> Package.put_version(version_1_2_5)
        |> Package.put_version(version_2_0_0)
        |> Package.put_version(version_1_0_0)

      assert Package.versions(package) == [
               version_2_0_0,
               version_1_2_5,
               version_1_0_0
             ]
    end
  end

  describe "fetch_version/2" do
    setup do
      version = %PackageVersion{
        name: "test",
        version: Version.parse!("1.2.3"),
        updated_at: @datetime
      }

      package =
        "test"
        |> Package.new()
        |> Package.put_version(version)

      {:ok, package: package, version: version}
    end

    test "found", %{package: package, version: version} do
      assert Package.fetch_version(package, Version.parse!("1.2.3")) ==
               {:ok, version}
    end

    test "not found", %{package: package} do
      assert Package.fetch_version(package, Version.parse!("1.2.4")) == :error
    end
  end

  describe "put_version/2" do
    @version_1_0_0 %PackageVersion{
      name: "test",
      version: Version.parse!("1.0.0"),
      updated_at: @datetime
    }
    @version_1_2_5 %PackageVersion{
      name: "test",
      version: Version.parse!("1.2.5"),
      updated_at: @datetime
    }
    @version_2_0_0 %PackageVersion{
      name: "test",
      version: Version.parse!("2.0.0"),
      updated_at: @datetime
    }
    @package Package.new("test")

    test "add version" do
      assert @package
             |> Package.put_version(@version_1_0_0)
             |> Package.put_version(@version_1_2_5)
             |> Package.put_version(@version_2_0_0)
             |> Map.fetch!(:versions) == [
               @version_2_0_0,
               @version_1_2_5,
               @version_1_0_0
             ]
    end

    test "put latest version" do
      assert @package.latest_version == nil

      assert @package
             |> Package.put_version(@version_1_0_0)
             |> Package.put_version(@version_1_2_5)
             |> Map.fetch!(:latest_version) == @version_1_2_5

      assert @package
             |> Package.put_version(@version_2_0_0)
             |> Package.put_version(@version_1_0_0)
             |> Map.fetch!(:latest_version) == @version_2_0_0
    end
  end

  describe "Jason.encode/1" do
    test "encode to JSON" do
      package =
        "test"
        |> Package.new()
        |> Package.put_version(%PackageVersion{
          name: "test",
          version: Version.parse!("1.2.3"),
          updated_at: NaiveDateTime.from_erl!({{2020, 1, 1}, {0, 0, 0}}),
          docs?: true
        })
        |> Package.put_version(%PackageVersion{
          name: "test",
          version: Version.parse!("1.0.0"),
          updated_at: NaiveDateTime.from_erl!({{2019, 12, 31}, {12, 34, 56}})
        })
        |> Package.put_version(%PackageVersion{
          name: "test",
          version: Version.parse!("2.0.0"),
          updated_at: NaiveDateTime.from_erl!({{2023, 09, 22}, {14, 32, 40}})
        })

      assert_json_equal Jason.encode!(package), """
        {
          "name": "test",
          "versions": [
            {
              "name": "test",
              "version": "2.0.0",
              "updated_at": "2023-09-22T14:32:40",
              "has_docs": false
            },
            {
              "name": "test",
              "version": "1.2.3",
              "updated_at": "2020-01-01T00:00:00",
              "has_docs": true
            },
            {
              "name": "test",
              "version": "1.0.0",
              "updated_at": "2019-12-31T12:34:56",
              "has_docs": false
            }
          ],
          "latest_version": {
            "name": "test",
            "version": "2.0.0",
            "updated_at": "2023-09-22T14:32:40",
            "has_docs": false
          }
        }
      """
    end
  end
end
