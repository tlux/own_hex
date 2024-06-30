defmodule OwnHex.Packages.PackageNotFoundError do
  @moduledoc """
  An error raised when a package or specific package version is not found.
  """

  @enforce_keys [:name]
  defexception [:name, :version]

  @type t :: %__MODULE__{
          name: String.t(),
          version: Version.t() | nil
        }

  def message(%{name: name, version: nil}) do
    "Package #{name} not found"
  end

  def message(%{name: name, version: version}) do
    "Package #{name}@#{Version.to_string(version)} not found"
  end
end
