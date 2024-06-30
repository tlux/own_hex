defmodule OwnHex.Packages.Storage do
  @moduledoc false

  @behaviour OwnHex.Packages.Behavior

  alias OwnHex.Config
  alias OwnHex.Packages.Package
  alias OwnHex.Packages.PackageNotFoundError
  alias OwnHex.Packages.PackageVersion
  alias OwnHex.Packages.Specification
  alias OwnHex.Packages.StorageError

  @take_max 100

  @impl true
  def list_packages(opts \\ []) do
    tarballs_dir = Config.tarballs_dir()

    case File.ls(tarballs_dir) do
      {:ok, filenames} ->
        {:ok, list_packages_with_opts(filenames, opts)}

      {:error, :enoent} ->
        {:ok, []}

      {:error, _} ->
        {:error, %StorageError{path: tarballs_dir}}
    end
  end

  defp list_packages_with_opts(filenames, opts) do
    filenames
    |> Enum.sort()
    |> Enum.reduce(%{}, fn filename, packages ->
      with {:ok, %{name: name} = specification} <-
             Specification.from_tarball(filename),
           true <- String.contains?(name, opts[:search] || ""),
           {:ok, package_version} <-
             PackageVersion.from_specification(specification) do
        Map.update(
          packages,
          name,
          Package.put_version(Package.new(name), package_version),
          fn package ->
            Package.put_version(package, package_version)
          end
        )
      else
        _ -> packages
      end
    end)
    |> Map.values()
    |> Stream.drop(Keyword.get(opts, :drop, 0))
    |> Stream.take(min(Keyword.get(opts, :take, @take_max), @take_max))
    |> sort_packages(opts[:sort])
  end

  defp sort_packages(packages, "recent") do
    Enum.sort_by(
      packages,
      & &1.latest_version.updated_at,
      {:desc, NaiveDateTime}
    )
  end

  defp sort_packages(packages, _), do: Enum.sort(packages, Package)

  @impl true
  def find_package(name) do
    with {:ok, packages} <- list_packages(search: name) do
      Enum.find_value(
        packages,
        {:error, %PackageNotFoundError{name: name}},
        fn
          %Package{name: ^name} = package -> {:ok, package}
          _ -> nil
        end
      )
    end
  end

  @impl true
  def find_package_version(
        %Specification{name: name, version: version} = specification
      ) do
    with {:package, {:ok, package}} <-
           {:package, find_package(specification.name)},
         {:version, {:ok, package_version}} <-
           {:version, Package.fetch_version(package, version)} do
      {:ok, package_version}
    else
      {:package, error} ->
        error

      {:version, :error} ->
        {:error, %PackageNotFoundError{name: name, version: version}}
    end
  end

  @impl true
  def package_version_exists?(%Specification{} = specification) do
    Config.tarballs_dir()
    |> Path.join(Specification.tarball(specification))
    |> File.exists?()
  end

  @impl true
  defdelegate publish_package(specification, path),
    to: OwnHex.Packages.Publisher

  @impl true
  defdelegate publish_docs(specification, path), to: OwnHex.Packages.Publisher
end
