defmodule OwnHex.Packages.Specification do
  @moduledoc """
  A Hex package specification containing a name and version.
  """

  alias OwnHex.Config
  alias OwnHex.Packages.SpecificationError

  @enforce_keys [:name, :version]
  defstruct [:name, :version]

  @type t :: %__MODULE__{
          name: String.t(),
          version: Version.t()
        }

  @name_regex ~r/\A[a-z0-9_]*[a-z0-9]\z/
  @tarball_regex ~r/\A(?<name>[a-z0-9_]*[a-z0-9])-(?<version>[0-9]+\.[0-9]+\.[0-9](-\w+)?).tar\z/i

  @doc """
  Creates a specification from a name and version.
  """
  @spec new(name :: String.t(), version :: String.t() | Version.t()) ::
          {:ok, t} | {:error, Exception.t()}
  def new(name, version) do
    with {:ok, name} <- parse_name(name),
         {:ok, version} <- parse_version(version) do
      {:ok, %__MODULE__{name: name, version: version}}
    end
  end

  defp parse_name(name) when is_nil(name) or name == "" do
    {:error, %SpecificationError{type: :missing, attribute: :name}}
  end

  defp parse_name(name) when is_binary(name) do
    if Regex.match?(@name_regex, name) do
      {:ok, name}
    else
      {:error, %SpecificationError{type: :invalid, attribute: :name}}
    end
  end

  defp parse_name(_) do
    {:error, %SpecificationError{type: :invalid, attribute: :name}}
  end

  defp parse_version(version) when is_nil(version) or version == "" do
    {:error, %SpecificationError{type: :missing, attribute: :version}}
  end

  defp parse_version(%Version{} = version), do: {:ok, version}

  defp parse_version(version) when is_binary(version) do
    case Version.parse(version) do
      {:ok, version} -> {:ok, version}
      _ -> {:error, %SpecificationError{type: :invalid, attribute: :version}}
    end
  end

  defp parse_version(_) do
    {:error, %SpecificationError{type: :invalid, attribute: :version}}
  end

  @doc """
  Creates a specification from a name and version.
  """
  @spec new!(name :: String.t(), version :: String.t() | Version.t()) ::
          t | no_return
  def new!(name, version) do
    case new(name, version) do
      {:ok, specification} -> specification
      {:error, error} -> raise error
    end
  end

  @doc """
  Creates a specification from a tarball filename.
  """
  @spec from_tarball(path :: Path.t()) :: {:ok, t} | :error
  def from_tarball(path) do
    with %{"name" => name, "version" => version}
         when is_binary(name) and is_binary(version) <-
           Regex.named_captures(@tarball_regex, Path.basename(path)),
         {:ok, version} <- Version.parse(version) do
      {:ok, %__MODULE__{name: name, version: version}}
    else
      _ ->
        :error
    end
  end

  @spec docs_dir(t) :: Path.t()
  def docs_dir(%__MODULE__{name: name, version: version}) do
    Path.join([Config.docs_dir(), name, to_string(version)])
  end

  @doc """
  Creates a tarball filename from a specification.
  """
  @spec tarball(t) :: String.t()
  def tarball(%__MODULE__{name: name, version: version}) do
    "#{name}-#{version}.tar"
  end

  @spec tarball_path(t) :: Path.t()
  def tarball_path(%__MODULE__{} = specification) do
    Path.join(Config.tarballs_dir(), tarball(specification))
  end

  @doc """
  Compares two specifications.
  """
  @spec compare(t, t) :: :lt | :eq | :gt
  def compare(%__MODULE__{} = specification, %__MODULE__{} = other) do
    cond do
      specification.name < other.name -> :lt
      specification.name > other.name -> :gt
      true -> Version.compare(specification.version, other.version)
    end
  end

  defimpl Jason.Encoder do
    def encode(specification, opts) do
      Jason.Encode.map(
        %{
          name: specification.name,
          version: Version.to_string(specification.version)
        },
        opts
      )
    end
  end
end
