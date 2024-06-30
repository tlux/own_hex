defmodule OwnHexWeb.Responses do
  @moduledoc false

  import Plug.Conn

  alias Plug.Conn.Status

  @spec status_resp(Plug.Conn.t(), integer | atom) :: Plug.Conn.t()
  def status_resp(conn, code_or_status) do
    send_resp(conn, code_or_status, reason_phrase(code_or_status))
  end

  defp reason_phrase(code_or_status) do
    code_or_status
    |> Status.code()
    |> Status.reason_phrase()
  end

  @spec invalid_param(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  def invalid_param(conn, param) do
    send_resp(conn, :bad_request, "Invalid or missing param: #{param}")
  end

  @spec not_found(Plug.Conn.t()) :: Plug.Conn.t()
  def not_found(conn) do
    status_resp(conn, :not_found)
  end

  @spec redirect(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  def redirect(conn, to) do
    conn
    |> put_resp_header("location", to)
    |> send_resp(:found, "You are being redirected")
  end

  @spec json(Plug.Conn.t(), integer | atom, any) :: Plug.Conn.t()
  def json(conn, code_or_status, payload) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code_or_status, Jason.encode!(payload))
  end

  @spec data_json(Plug.Conn.t(), integer | atom, any) :: Plug.Conn.t()
  def data_json(conn, code_or_status \\ :ok, data) do
    json(conn, code_or_status, %{data: data})
  end

  @spec error_json(Plug.Conn.t(), integer | atom, any) :: Plug.Conn.t()
  def error_json(conn, code_or_status \\ :internal_server_error, error) do
    json(conn, code_or_status, %{error: error})
  end

  @spec error_status_json(Plug.Conn.t(), integer | atom) :: Plug.Conn.t()
  def error_status_json(conn, code_or_status) do
    error_json(conn, code_or_status, reason_phrase(code_or_status))
  end
end
