defmodule OwnHex.Packages.Publisher.StorageTest do
  use ExUnit.Case, async: false

  import Mox

  alias OwnHex.Config
  alias OwnHex.Packages.Publisher.Storage
  alias OwnHex.Packages.Specification
  alias OwnHex.Packages.StorageError
  alias OwnHex.Registry
  alias OwnHex.Unpacker.UnpackError

  @tarball_path "test/fixtures/archive-1.2.3.tar"
  @specification Specification.new!("foo", "1.2.3")

  setup :verify_on_exit!

  setup do
    on_exit(fn ->
      File.rm_rf!(Config.registry_dir())
      File.rm_rf!(Config.docs_dir())
    end)
  end

  describe "publish_package/2" do
    test "successfully store tarball" do
      expect(Registry.Mock, :rebuild_registry, fn -> :ok end)

      refute File.exists?(Specification.tarball_path(@specification))
      assert :ok = Storage.publish_package(@specification, @tarball_path)
      assert File.exists?(Specification.tarball_path(@specification))
    end

    test "package already exists" do
      File.mkdir_p!(Config.tarballs_dir())
      tarball_path = Specification.tarball_path(@specification)
      File.cp!(@tarball_path, tarball_path)

      assert :conflict = Storage.publish_package(@specification, @tarball_path)
      assert File.exists?(tarball_path)
    end

    test "rollback when rebuilding registry failed" do
      error = %Registry.BuildError{reason: "something went wrong"}

      expect(Registry.Mock, :rebuild_registry, fn ->
        {:error, error}
      end)

      refute File.exists?(Specification.tarball_path(@specification))

      assert Storage.publish_package(@specification, @tarball_path) ==
               {:error, error}

      refute File.exists?(Specification.tarball_path(@specification))
    end

    test "storage error" do
      path = "/foo/bar"

      assert Storage.publish_package(@specification, path) ==
               {:error, %StorageError{path: path}}
    end
  end

  describe "publish_docs/2" do
    setup do
      {:ok, docs_dir: Specification.docs_dir(@specification)}
    end

    test "successfully store docs", %{docs_dir: docs_dir} do
      File.mkdir_p!(Config.tarballs_dir())
      File.cp!(@tarball_path, Specification.tarball_path(@specification))

      refute File.exists?(docs_dir)
      assert :ok = Storage.publish_docs(@specification, @tarball_path)
      assert File.exists?(docs_dir)
    end

    test "package not found", %{docs_dir: docs_dir} do
      refute File.exists?(docs_dir)
      assert :not_found = Storage.publish_docs(@specification, @tarball_path)
      refute File.exists?(docs_dir)
    end

    test "docs already exists", %{docs_dir: docs_dir} do
      File.mkdir_p!(Config.tarballs_dir())
      File.mkdir_p!(docs_dir)
      File.cp!(@tarball_path, Specification.tarball_path(@specification))

      assert File.exists?(docs_dir)
      assert :conflict = Storage.publish_docs(@specification, @tarball_path)
      assert File.exists?(docs_dir)
    end

    test "unpack error" do
      invalid_path = "test/fixtures/invalid-archive.tar"

      File.mkdir_p!(Config.tarballs_dir())
      File.cp!(invalid_path, Specification.tarball_path(@specification))

      assert {:error, %UnpackError{}} =
               Storage.publish_docs(@specification, invalid_path)
    end
  end
end
