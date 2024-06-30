defmodule OwnHex.Packages.Package do
  @moduledoc """
  A struct that contains metadata about a package.
  """

  alias OwnHex.Packages.PackageVersion

  @enforce_keys [:name]
  defstruct [:name, versions: [], latest_version: nil]

  @type t :: %__MODULE__{
          name: String.t(),
          versions: [PackageVersion.t()],
          latest_version: PackageVersion.t() | nil
        }

  @spec new(name :: String.t()) :: t
  def new(name) when is_binary(name) do
    %__MODULE__{name: name}
  end

  @spec compare(t, t) :: :lt | :eq | :gt
  def compare(%__MODULE__{} = package, %__MODULE__{} = other) do
    cond do
      package.name == other.name -> :eq
      package.name < other.name -> :lt
      package.name > other.name -> :gt
    end
  end

  @spec versions(t) :: [PackageVersion.t()]
  def versions(%__MODULE__{versions: versions}) do
    Enum.sort(versions, fn version, other ->
      case PackageVersion.compare(version, other) do
        :lt -> false
        _ -> true
      end
    end)
  end

  @spec fetch_version(t, Version.t()) :: {:ok, PackageVersion.t()} | :error
  def fetch_version(
        %__MODULE__{versions: package_versions},
        %Version{} = version
      ) do
    Enum.find_value(package_versions, :error, fn
      %PackageVersion{version: ^version} = package_version ->
        {:ok, package_version}

      _ ->
        nil
    end)
  end

  @spec put_version(t, PackageVersion.t()) :: t
  def put_version(%__MODULE__{} = package, %PackageVersion{} = version) do
    %__MODULE__{
      package
      | versions: [version | package.versions],
        latest_version: min_version(package.latest_version, version)
    }
  end

  defp min_version(nil, version), do: version

  defp min_version(latest_version, version) do
    if PackageVersion.compare(version, latest_version) == :gt do
      version
    else
      latest_version
    end
  end

  defimpl Jason.Encoder do
    alias OwnHex.Packages.Package

    def encode(%{name: name, latest_version: latest_version} = package, opts) do
      Jason.Encode.map(
        %{
          name: name,
          versions: Package.versions(package),
          latest_version: latest_version
        },
        opts
      )
    end
  end
end
