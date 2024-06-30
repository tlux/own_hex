defmodule OwnHex.Packages do
  @moduledoc """
  Facade for the package manager.
  """

  @behaviour OwnHex.Packages.Behavior

  @implementation Application.compile_env(
                    :own_hex,
                    __MODULE__,
                    __MODULE__.Storage
                  )

  @doc """
  Lists all packages.
  """
  defdelegate list_packages(), to: @implementation

  @doc """
  Lists packages with the given options.

  ## Options

  * `:search` - search for packages with this name
  * `:take` (default: `100`) - number of packages to return
  * `:drop` (default: `0`) - number of packages to skip from the beginning of
    the list
  """
  defdelegate list_packages(opts), to: @implementation

  @doc """
  Finds a package by name.
  """
  defdelegate find_package(name), to: @implementation

  @doc """
  Finds a package version by specification.
  """
  defdelegate find_package_version(specification), to: @implementation

  @doc """
  Checks if a package exists.
  """
  defdelegate package_version_exists?(specification), to: @implementation

  @doc """
  Publishes a package.
  """
  defdelegate publish_package(specification, path), to: @implementation

  @doc """
  Publishes docs for a package.
  """
  defdelegate publish_docs(specification, path), to: @implementation
end
