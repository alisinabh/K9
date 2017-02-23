defmodule K9.Watchdog.DnsWatchdog do
  @moduledoc """
  Tools for checking domain name related issues like:
    - Domain Expiray
    - Domain NS validation
    - Name Server reachability and response time
    - Record timeouts
    - Record changes
    - Domain SSL public records
  """
  use K9.Watchdog

  import K9.Tools.DnsTools

  @doc """
  Checks DNS integrity of an specific FQDN.
  Returns {:ok, :dns_ok} if every thing is ok or {:error, :reason, "Reason string"} in case of error(s)

  ## Parameters
    - param1: a list in following order: [``fqdn`` as String, ``ip`` as Tuple, ``min_ttl`` as Integer, ``max_ttl`` as Integer]
  """
  @spec bark({K9.Tools.DnsTools.dns_fqdn, Tuple.t, Integer.t, Integer.t}) :: K9.Watchdog.bark_resp
  def bark({fqdn, ip = {_, _, _, _}, min_ttl, max_ttl}) do
    case resolve(fqdn) do
      {:ok, ^ip, ttl} ->
        cond do
          ttl <= max_ttl and ttl >= min_ttl ->
            {:ok, :dns_ok}
          true -> {:error, :dnt_ttl_error, "DNS TTL error: " <> to_string(ttl) <> " for: " <> to_string(fqdn)}
        end
      {:ok, wrong_ip, _} ->
        {:error,
         :wrong_ip,
         to_string(fqdn) <> " is redirected to wrong ip: " <> to_string(:inet_parse.ntoa(wrong_ip))
          <> " instead of: " <> to_string(:inet_parse.ntoa(ip))}
      {:error, type} -> {:error, type}
    end
  end

  @spec bark({K9.Tools.DnsTools.dns_fqdn, Integer.t}) :: K9.Watchdog.bark_resp
  def bark({fqdn, ip}) do
    bark {fqdn, ip, 3600, 21600}
  end
end
