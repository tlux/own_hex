defmodule OwnHex.Unpacker.UnpackError do
  @enforce_keys [:reason]
  defexception [:reason]

  @type t :: %__MODULE__{reason: term}

  def message(%{reason: reason}) do
    "Error unpacking archive: #{inspect(reason)}"
  end
end
