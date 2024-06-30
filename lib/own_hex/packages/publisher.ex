defmodule OwnHex.Packages.Publisher do
  @moduledoc false

  @behaviour OwnHex.Packages.Publisher.Behavior

  @implementation Application.compile_env(
                    :own_hex,
                    __MODULE__,
                    __MODULE__.Server
                  )

  defdelegate publish_package(specification, path), to: @implementation

  defdelegate publish_docs(specification, path), to: @implementation
end
