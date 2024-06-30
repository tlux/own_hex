defmodule OwnHex.JsonAssertions do
  @moduledoc """
  Provides test assertions for JSON.
  """

  import ExUnit.Assertions

  @doc """
  Asserts that two JSON strings are structurally equal.
  """
  def assert_json_equal(first, second) do
    assert Jason.decode!(first) == Jason.decode!(second)
  end
end
