defmodule OwnHexWeb.Params do
  @moduledoc false

  @type param_type :: :int | :string

  @spec param(Plug.Conn.t(), atom, param_type, any) :: any
  def param(conn, key, type, default \\ nil)

  def param(conn, key, :int, default) do
    case Integer.parse(param(conn, key, :string, "")) do
      {int_value, ""} -> int_value
      _ -> default
    end
  end

  def param(conn, key, :string, default) do
    case Map.fetch(conn.params, to_string(key)) do
      {:ok, value} when is_binary(value) -> String.trim(value)
      _ -> default
    end
  end
end
