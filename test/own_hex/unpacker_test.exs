defmodule OwnHex.UnpackerTest do
  use ExUnit.Case, async: true

  alias OwnHex.Unpacker

  @compressed_archive_path "test/fixtures/archive-1.2.3.tar.gz"
  @uncompressed_archive_path "test/fixtures/archive-1.2.3.tar"

  setup do
    tmp_path = Path.join(["tmp", "unpacker_test", UUID.uuid4()])
    File.mkdir_p!(tmp_path)

    on_exit(fn ->
      File.rm_rf!(tmp_path)
    end)

    extracted_file_path = Path.join(tmp_path, "file.txt")

    {:ok, tmp_path: tmp_path, extracted_file_path: extracted_file_path}
  end

  describe "unpack_file/1" do
    test "uncompressed tar file", %{
      tmp_path: tmp_path,
      extracted_file_path: extracted_file_path
    } do
      refute File.exists?(extracted_file_path)
      assert Unpacker.unpack_file(@uncompressed_archive_path, tmp_path) == :ok
      assert File.exists?(extracted_file_path)
    end

    test "compressed tar file", %{
      tmp_path: tmp_path,
      extracted_file_path: extracted_file_path
    } do
      refute File.exists?(extracted_file_path)
      assert Unpacker.unpack_file(@compressed_archive_path, tmp_path) == :ok
      assert File.exists?(extracted_file_path)
    end

    test "invalid archive with correct extension", %{tmp_path: tmp_path} do
      assert Unpacker.unpack_file(
               "test/fixtures/invalid-archive.tar",
               tmp_path
             ) == {:error, %Unpacker.UnpackError{reason: :eof}}
    end

    test "invalid archive with incorrect extension", %{tmp_path: tmp_path} do
      assert Unpacker.unpack_file(
               "test/fixtures/private_key.pem",
               tmp_path
             ) ==
               {:error,
                %Unpacker.InvalidArchiveError{filename: "private_key.pem"}}
    end

    test "missing file", %{tmp_path: tmp_path} do
      archive_path = "test/fixtures/missing-file.tar"

      assert Unpacker.unpack_file(archive_path, tmp_path) ==
               {:error, %Unpacker.UnpackError{reason: {archive_path, :enoent}}}
    end
  end
end
