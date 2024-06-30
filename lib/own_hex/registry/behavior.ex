defmodule OwnHex.Registry.Behavior do
  @moduledoc """
  Behaviour for services that update the registry.
  """

  @callback rebuild_registry() :: :ok | {:error, Exception.t()}
end
