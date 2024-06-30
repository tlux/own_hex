defmodule OwnHex.Ownership do
  @moduledoc """
  Provides helpers for file ownership management.
  """

  alias OwnHex.Config

  @doc """
  Recursively updates the owner of the given file or directory based on the application
  configuration.
  """
  @spec fix_owner(path :: Path.t()) :: :ok | :error
  def fix_owner(path) do
    update_owner(path, uid: Config.owner_uid(), gid: Config.owner_gid())
  end

  @doc """
  Recursively updates the owner of the given file or directory.

  ## Options

  * `:uid` - The user ID of the owner
  * `:gid` - The group ID of the owner
  """
  @spec update_owner(path :: Path.t(), opts :: Keyword.t()) :: :ok | :error
  def update_owner(path, opts \\ []) do
    uid = opts[:uid]
    gid = opts[:gid]

    result =
      cond do
        uid && gid ->
          System.cmd("chown", ["-R", "#{uid}:#{gid}", path])

        uid ->
          System.cmd("chown", ["-R", to_string(uid), path])

        gid ->
          System.cmd("chgrp", ["-R", gid, path])

        true ->
          :noop
      end

    case result do
      :noop -> :ok
      {_, 0} -> :ok
      _ -> :error
    end
  end
end
