defmodule OwnHex.Registry.BuildError do
  @enforce_keys [:reason]
  defexception [:reason]

  @type t :: %__MODULE__{reason: String.t()}

  def message(%{reason: reason}) do
    "Failed to build registry: #{reason}"
  end
end
