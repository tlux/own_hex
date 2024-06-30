defmodule OwnHex.Unpacker do
  @moduledoc """
  Provides helpers to unpack file from common archive formats.
  """

  alias OwnHex.Unpacker.{InvalidArchiveError, UnpackError}

  @doc """
  Unpacks the given file to the given destination path.
  """
  @spec unpack_file(path :: Path.t(), to :: Path.t()) ::
          :ok | {:error, Exception.t()}
  def unpack_file(path, to) when is_binary(path) do
    with {:ok, compressed?} <- compressed_file(path),
         :ok <- ensure_dir_exists(to) do
      extract_tarball(path, to, compressed?)
    end
  end

  defp compressed_file(path) do
    basename = path |> Path.basename() |> String.downcase()

    cond do
      String.ends_with?(basename, ".tar.gz") ->
        {:ok, true}

      String.ends_with?(basename, ".tgz") ->
        {:ok, true}

      String.ends_with?(basename, ".tar") ->
        {:ok, false}

      true ->
        {:error, %InvalidArchiveError{filename: basename}}
    end
  end

  defp ensure_dir_exists(path) do
    case File.mkdir_p(path) do
      :ok -> :ok
      {:error, reason} -> {:error, %UnpackError{reason: reason}}
    end
  end

  defp extract_tarball(path, to, compressed) do
    case :erl_tar.extract(path, [cwd: to] ++ compressed_opt(compressed)) do
      {:error, reason} ->
        {:error, %UnpackError{reason: reason}}

      _ ->
        :ok
    end
  end

  defp compressed_opt(true), do: [:compressed]
  defp compressed_opt(false), do: []
end
