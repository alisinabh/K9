defmodule K9.Watchdog.PortWatchdog do
  @moduledoc """
  Deamon and tools for checking a port availability on services
  """
  use K9.Watchdog

  import K9.Tools.DnsTools

  ###
  # Watchdog API
  ###

  @doc """
  Whatchdog bark api which checks for port availability on a host.

  ## Parameters
    - arg1: a tuple in format of ``{host, port, timeout}`` host is stgirng or an erlang ip, port is an int in range of 0-65536. timeout is int milliseconds.

  ## Example
    iex> K9.Watchdog.PortWatchdog.bark {"google.com", 80, 10000}
    :ok
  """
  def bark({server, port, timeout}) do
    {:ok, ip} = get_server_ip server

    case :gen_tcp.connect(ip, port, [:binary, packet: :raw, active: false], timeout) do
      {:ok, _} -> :ok
      _ -> {:error, :port_con_error}
    end
  end

  def bark({server, port}), do: bark({server, port, 10000})

  ###
  # Port Watching tools
  ###

  defp get_server_ip(fqdn) when is_list(fqdn) do
    {:ok, ip, _} = K9.Tools.DnsTools.resolve fqdn
    {:ok, ip}
  end

  defp get_server_ip(fqdn) when is_binary(fqdn), do: fqdn |> String.to_charlist |> get_server_ip

  defp get_server_ip(ip = {_, _, _, _}), do: ip
end
