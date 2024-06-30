defmodule OwnHex.Packages.PackageVersion do
  @moduledoc """
  A struct that contains metadata about a package version.
  """

  alias OwnHex.Packages.PackageNotFoundError
  alias OwnHex.Packages.Specification

  @enforce_keys [:name, :version, :updated_at]
  defstruct [:name, :version, :updated_at, docs?: false]

  @type t :: %__MODULE__{
          name: String.t(),
          version: Version.t(),
          updated_at: NaiveDateTime.t(),
          docs?: false
        }

  @doc false
  @spec from_specification(specification :: Specification.t()) ::
          {:ok, t} | {:error, Exception.t()}
  def from_specification(%Specification{} = specification) do
    with {:ok, %{mtime: mtime}} <-
           File.stat(Specification.tarball_path(specification)),
         {:ok, updated_at} <- NaiveDateTime.from_erl(mtime) do
      {:ok,
       %__MODULE__{
         name: specification.name,
         version: specification.version,
         updated_at: updated_at,
         docs?: File.dir?(Specification.docs_dir(specification))
       }}
    else
      _ ->
        {:error,
         %PackageNotFoundError{
           name: specification.name,
           version: specification.version
         }}
    end
  end

  @doc false
  @spec from_specification!(specification :: Specification.t()) :: t | no_return
  def from_specification!(%Specification{} = specification) do
    case from_specification(specification) do
      {:ok, package_version} -> package_version
      {:error, error} -> raise error
    end
  end

  @doc """
  Compares a package version to another one.
  """
  @spec compare(t, t) :: :lt | :eq | :gt
  def compare(%__MODULE__{} = version, %__MODULE__{} = other) do
    Version.compare(version.version, other.version)
  end

  defimpl Jason.Encoder do
    def encode(
          %{
            name: name,
            version: version,
            updated_at: updated_at,
            docs?: docs?
          },
          opts
        ) do
      Jason.Encode.map(
        %{
          name: name,
          version: Version.to_string(version),
          updated_at: NaiveDateTime.to_iso8601(updated_at),
          has_docs: docs?
        },
        opts
      )
    end
  end
end
