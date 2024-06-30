defmodule OwnHex.Config do
  @moduledoc """
  Provides easy access to the application config.
  """

  @app :own_hex

  @doc """
  The name of the registry.
  """
  @spec registry_name() :: String.t()
  def registry_name, do: Application.fetch_env!(@app, :registry_name)

  @doc """
  The port that the HTTP server is using.
  """
  @spec port() :: integer
  def port, do: Application.fetch_env!(@app, :port)

  @doc """
  The dir where all package data is stored in.
  """
  @spec registry_dir() :: Path.t()
  def registry_dir do
    @app
    |> Application.fetch_env!(:registry_dir)
    |> expand_path()
  end

  @doc """
  The dir where tarballs are stored in.
  """
  @spec tarballs_dir() :: Path.t()
  def tarballs_dir, do: Path.join(registry_dir(), "tarballs")

  @doc """
  The dir where all docs are stored in.
  """
  @spec docs_dir() :: Path.t()
  def docs_dir do
    @app
    |> Application.fetch_env!(:docs_dir)
    |> expand_path()
  end

  @doc """
  The path to the private key.
  """
  @spec private_key_path() :: Path.t()
  def private_key_path do
    @app
    |> Application.fetch_env!(:private_key_path)
    |> expand_path()
  end

  @doc """
  ID of the user that owns the public dir.
  """
  @spec owner_uid() :: non_neg_integer | nil
  def owner_uid do
    Application.get_env(@app, :file_ownership)[:uid]
  end

  @doc """
  ID of the group that owns the public dir.
  """
  @spec owner_gid() :: non_neg_integer | nil
  def owner_gid do
    Application.get_env(@app, :file_ownership)[:gid]
  end

  @doc """
  A keyword list containing username and password for basic auth or nil when no
  authentication should be used.
  """
  @spec auth() :: Keyword.t() | nil
  def auth do
    credentials = Application.get_env(:own_hex, :auth)

    if credentials[:username] && credentials[:password] do
      credentials
    end
  end

  defp expand_path(path), do: Path.absname(path, File.cwd!())
end
