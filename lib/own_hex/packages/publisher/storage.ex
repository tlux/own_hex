defmodule OwnHex.Packages.Publisher.Storage do
  @moduledoc false

  @behaviour OwnHex.Packages.Publisher.Behavior

  alias OwnHex.Config
  alias OwnHex.Packages.Specification
  alias OwnHex.Packages.StorageError
  alias OwnHex.Registry
  alias OwnHex.Unpacker

  @impl true
  def publish_package(%Specification{} = specification, path) do
    tarball_path = Specification.tarball_path(specification)

    with {:conflict, false} <- {:conflict, File.exists?(tarball_path)},
         {:dir, :ok} <- {:dir, File.mkdir_p(Config.tarballs_dir())},
         {:store, :ok} <- {:store, File.cp(path, tarball_path)},
         {:registry, :ok} <- {:registry, Registry.rebuild_registry()} do
      :ok
    else
      {:conflict, true} ->
        :conflict

      {:registry, error} ->
        File.rm(tarball_path)
        error

      _ ->
        {:error, %StorageError{path: path}}
    end
  end

  @impl true
  def publish_docs(%Specification{} = specification, path) do
    docs_dir = Specification.docs_dir(specification)

    with {:exists, true} <-
           {:exists, File.exists?(Specification.tarball_path(specification))},
         {:conflict, false} <- {:conflict, File.exists?(docs_dir)},
         {:dir, :ok} <- {:dir, File.mkdir_p(docs_dir)},
         {:unpack, :ok} <- {:unpack, Unpacker.unpack_file(path, docs_dir)} do
      :ok
    else
      {:exists, false} -> :not_found
      {:conflict, true} -> :conflict
      {:unpack, error} -> error
      _ -> {:error, %StorageError{path: path}}
    end
  end
end
