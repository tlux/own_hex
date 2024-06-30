defmodule OwnHex.Packages.Behavior do
  @moduledoc """
  Behaviour for services that handle publication of Hex packages.
  """

  alias OwnHex.Packages.Package
  alias OwnHex.Packages.PackageVersion
  alias OwnHex.Packages.Specification

  @doc """
  Lists all packages.
  """
  @callback list_packages() ::
              {:ok, [Package.t()]} | {:error, Exception.t()}

  @doc """
  Lists packages with the given options.

  ## Options

  * `:search` - search for packages with this name
  * `:take` (default: `100`) - number of packages to return
  * `:drop` (default: `0`) - number of packages to skip from the beginning of
    the list
  """
  @callback list_packages(opts :: Keyword.t()) ::
              {:ok, [Package.t()]} | {:error, Exception.t()}

  @doc """
  Finds a package by name.
  """
  @callback find_package(name :: String.t()) ::
              {:ok, Package.t()} | {:error, Exception.t()}

  @doc """
  Finds a package version by specification.
  """
  @callback find_package_version(specification :: Specification.t()) ::
              {:ok, PackageVersion.t()} | {:error, Exception.t()}

  @doc """
  Checks if a package exists.
  """
  @callback package_version_exists?(specification :: Specification.t()) ::
              boolean

  @doc """
  Publishes a package.
  """
  @callback publish_package(
              specification :: Specification.t(),
              path :: Path.t()
            ) :: :ok | :conflict | {:error, Exception.t()}

  @doc """
  Publishes docs for a package.
  """
  @callback publish_docs(
              specification :: Specification.t(),
              path :: Path.t()
            ) :: :ok | :not_found | :conflict | {:error, Exception.t()}
end
