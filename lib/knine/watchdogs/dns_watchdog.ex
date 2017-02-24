defmodule Knine.Watchdog.DnsWatchdog do
  @moduledoc """
  Tools for checking domain name related issues like:
    - Domain Expiray
    - Domain NS validation
    - Name Server reachability and response time
    - Record timeouts
    - Record changes
    - Domain SSL public records
  """
  use Knine.Watchdog

  import Knine.Tools.DnsTools

  ###
  # Watchdog API
  ###

  @doc """
  Checks DNS integrity of an specific FQDN.
  Returns {:ok, :dns_ok} if every thing is ok or {:error, :reason, "Reason string"} in case of error(s)

  ## Parameters
    - param1: a list in following order: [``fqdn`` as String, ``ip`` as Tuple, ``min_ttl`` as Integer, ``max_ttl`` as Integer]
  """
  @spec bark({Knine.Tools.DnsTools.dns_fqdn, Tuple.t, Integer.t, Integer.t}) :: Knine.Watchdog.bark_resp
  def bark({fqdn, ip = {_, _, _, _}, min_ttl, max_ttl}) do
    case resolve(fqdn) do
      {:ok, ^ip, ttl} ->
        cond do
          ttl <= max_ttl and ttl >= min_ttl ->
            {:ok, :dns_ok}
          true -> {:error, :dns_ttl_error, "DNS TTL error: " <> to_string(ttl) <> " for: " <> to_string(fqdn)}
        end
      {:ok, wrong_ip, _} ->
        {:error,
         :wrong_ip,
         to_string(fqdn) <> " is redirected to wrong ip: " <> to_string(:inet_parse.ntoa(wrong_ip))
          <> " instead of: " <> to_string(:inet_parse.ntoa(ip))}
      {:error, type} -> {:error, type}
    end
  end

  @spec bark({Knine.Tools.DnsTools.dns_fqdn, Integer.t}) :: Knine.Watchdog.bark_resp
  def bark({fqdn, ip}) do
    bark {fqdn, ip, 3600, 21600}
  end
end
