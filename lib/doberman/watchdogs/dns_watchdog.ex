defmodule Doberman.DnsWatchdog do
  @moduledoc """
  Tools for checking domain name related issues like:
    - Domain Expiray
    - Domain NS validation
    - Name Server reachability and response time
    - Record timeouts
    - Record changes
    - Domain SSL public records
  """
  @behaviour Doberman.Watchdog

  @doc """
  Resolves a domain name and returns ``ip`` and ``ttl``

  ## Parameters
    - fqdn: fully qualified domain name as a char array
  """
  @spec resolve(char_list) :: {:ok, Tuple.t, Integer.t} | {:error, :reason}
  def resolve(fqdn, nameservers \\ [{{8, 8, 8, 8}, 53}]) do
    case :inet_res.resolve(fqdn, :in, :a, nameservers: nameservers) do
      {:ok, {:dns_rec, _, _, [{:dns_rr, ^fqdn, :a, :in, _, ttl, ip, _, _, _}], _, _}} ->
        {:ok, ip, ttl}
      _ -> {:error, :dns_resp_error}
    end
  end


  def bark([fqdn, ip, min_ttl, max_ttl]) do
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
          <> " insted of: " <> to_string(:inet_parse.ntoa(ip))}
      {:error, type} -> {:error, type}
      _ -> {:error, :unknown}
    end
  end
end
