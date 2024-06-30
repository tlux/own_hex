defmodule OwnHex.Unpacker.InvalidArchiveError do
  @enforce_keys [:filename]
  defexception [:filename]

  @type t :: %__MODULE__{filename: String.t()}

  def message(%{filename: filename}) do
    "Invalid archive: #{filename}"
  end
end
