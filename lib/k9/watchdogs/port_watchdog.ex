defmodule K9.Watchdog.PortWatchdog do
  @moduledoc """
  Deamon and tools for checking a port availability on services
  """
  use K9.Watchdog

  import K9.Tools.DnsTools

  def bark({server, port, timeout}) do
    {:ok, ip} = get_server_ip server

    case :gen_tcp.connect(ip, port, [:binary, packet: :raw, active: false], timeout) do
      {:ok, _} -> :ok
      _ -> {:error, :port_con_error}
    end
  end

  def bark({server, port}), do: bark({server, port, 10000})

  defp get_server_ip(fqdn) when is_list(fqdn) do
    {:ok, ip, _} = K9.Tools.DnsTools.resolve fqdn
    {:ok, ip}
  end

  defp get_server_ip(fqdn) when is_binary(fqdn), do: fqdn |> get_server_ip

  defp get_server_ip(ip = {_, _, _, _}), do: ip
end
