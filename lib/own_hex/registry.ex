defmodule OwnHex.Registry do
  @moduledoc """
  Facade for the Hex registry.
  """

  @behaviour OwnHex.Registry.Behavior

  @implementation Application.compile_env(
                    :own_hex,
                    __MODULE__,
                    OwnHex.Registry.ViaMix
                  )

  @doc """
  Rebuilds the registry.
  """
  @impl true
  defdelegate rebuild_registry(), to: @implementation
end
