defmodule OwnHex.Packages.Publisher.Behavior do
  @moduledoc false

  alias OwnHex.Packages.Specification

  @callback publish_package(
              specification :: Specification.t(),
              path :: Path.t()
            ) :: :ok | :conflict | {:error, Exception.t()}

  @callback publish_docs(
              specification :: Specification.t(),
              path :: Path.t()
            ) :: :ok | :not_found | :conflict | {:error, Exception.t()}
end
