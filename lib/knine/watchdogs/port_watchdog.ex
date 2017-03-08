defmodule Knine.Watchdog.PortWatchdog do
  @moduledoc """
  Deamon and tools for checking a port availability on services
  """
  use Knine.Watchdog

  import Knine.Tools.DnsTools

  @type port_number :: 1..65536
  @type ip_address :: {Integer.t, Integer.t, Integer.t, Integer.t}

  ###
  # Watchdog API
  ###

  @doc """
  Whatchdog bark api which checks for port availability on a host.

  ## Parameters
    - arg1: a tuple in format of ``{host, port, timeout}`` host is string or an erlang ip, port is an int in range of 1-65536. timeout is int milliseconds.

  ## Example
    iex> Knine.Watchdog.PortWatchdog.bark {"google.com", 80, 10000}
    :ok
  """
  @spec bark({String.t | List.t, port_number, Integer.t}) :: Knine.Watchdog.bark_resp
  def bark({server, port, timeout}) do
    case get_server_ip server do
      {:ok, ip} ->
        case :gen_tcp.connect(ip, port, [:binary, packet: :raw, active: false], timeout) do
          {:ok, _} -> {:low, nil}
          _ ->
            {:critical, "TCP Connection error to: #{to_string(:inet_parse.ntoa(ip))}:#{port}"}
        end
      error -> error
    end
  end

  @spec bark({String.t | List.t, port_number}) :: Knine.Watchdog.bark_resp
  def bark({server, port}), do: bark({server, port, 10000})

  ###
  # Port Watching tools
  ###

  @spec get_server_ip(List.t | String.t | ip_address) :: {:ok, ip_address} | {:error, atom()}
  defp get_server_ip(fqdn) when is_list(fqdn) do
    case resolve fqdn do
      {:ok, ip, _} -> {:ok, ip}
      _ -> {:major, "Domain resolve error: #{fqdn}"}
    end
  end

  defp get_server_ip(fqdn) when is_binary(fqdn), do: fqdn |> String.to_charlist |> get_server_ip

  defp get_server_ip(ip = {_, _, _, _}) when is_tuple(ip), do: ip
end
