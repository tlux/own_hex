defmodule OwnHex.Packages.Publisher.Server do
  @moduledoc false

  @behaviour OwnHex.Packages.Publisher.Behavior

  use GenServer

  require Logger

  @storage Application.compile_env(
             :own_hex,
             __MODULE__,
             OwnHex.Packages.Publisher.Storage
           )

  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def publish_package(specification, path) do
    GenServer.call(__MODULE__, {:publish_package, specification, path})
  end

  @impl true
  def publish_docs(specification, path) do
    GenServer.call(__MODULE__, {:publish_docs, specification, path})
  end

  # Server

  @impl GenServer
  def init(_init_arg) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:publish_package, specification, path}, _from, state) do
    {:reply, @storage.publish_package(specification, path), state}
  end

  @impl GenServer
  def handle_call({:publish_docs, specification, path}, _from, state) do
    {:reply, @storage.publish_docs(specification, path), state}
  end
end
