defmodule OwnHex.Packages.SpecificationError do
  @enforce_keys [:type, :attribute]
  defexception [:type, :attribute]

  @type t :: %__MODULE__{
          type: :invalid | :missing,
          attribute: atom
        }

  def message(%{type: :missing, attribute: attribute}) do
    "Missing attribute: #{attribute}"
  end

  def message(%{attribute: attribute}) do
    "Invalid attribute: #{attribute}"
  end
end
