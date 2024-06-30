defmodule OwnHex.Registry.ViaMix do
  @moduledoc """
  Rebuilds the Hex registry using the `mix hex.registry` task.
  """

  @behaviour OwnHex.Registry.Behavior

  alias OwnHex.Config
  alias OwnHex.Ownership
  alias OwnHex.Registry.BuildError

  @impl true
  def rebuild_registry do
    dir = Config.registry_dir()

    case System.cmd(
           "mix",
           [
             "hex.registry",
             "build",
             dir,
             "--name",
             Config.registry_name(),
             "--private-key",
             Config.private_key_path()
           ],
           stderr_to_stdout: true
         ) do
      {_, 0} ->
        Ownership.fix_owner(dir)
        :ok

      {out, _} ->
        {:error, %BuildError{reason: String.trim_trailing(out)}}
    end
  end
end
