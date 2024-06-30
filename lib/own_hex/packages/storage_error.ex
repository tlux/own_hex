defmodule OwnHex.Packages.StorageError do
  defexception [:path]

  @type t :: %__MODULE__{path: Path.t()}

  def message(%{path: path}) do
    "Failed to read from or write to package storage while accessing #{path}"
  end
end
