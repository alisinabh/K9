defmodule K9.DnsWatchdog do
  @moduledoc """
  Tools for checking domain name related issues like:
    - Domain Expiray
    - Domain NS validation
    - Name Server reachability and response time
    - Record timeouts
    - Record changes
    - Domain SSL public records
  """
  require Logger

  @behaviour K9.Watchdog

  @type dns_fqdn :: char_list

  @doc """
  Resolves a domain name and returns ``ip`` and ``ttl``

  ## Parameters
    - fqdn: fully qualified domain name as a char array
  """
  @spec resolve(dns_fqdn) :: {:ok, Tuple.t, Integer.t} | {:error, :reason}
  def resolve(fqdn, nameservers \\ [{{8, 8, 8, 8}, 53}]) do
    case :inet_res.resolve(fqdn, :in, :a, nameservers: nameservers) do
      {:ok, {:dns_rec, _, _, [{:dns_rr, ^fqdn, :a, :in, _, ttl, ip, _, _, _}], _, _}} ->
        {:ok, ip, ttl}
      _ -> {:error, :dns_resp_error}
    end
  end

  @doc "Same as bark([fqdn, ip, min_ttl, max_ttl]) with min and max ttl defaults"
  @spec bark({dns_fqdn, Integer.t}) :: K9.Watchdog.bark_resp
  def bark({fqdn, ip}) do
    bark {fqdn, ip, 3600, 21600}
  end

  @doc """
  Checks DNS integrity of an specific FQDN.
  Returns {:ok, :dns_ok} if every thing is ok or {:error, :reason, "Reason string"} in case of error(s)

  ## Parameters
    - param1: a list in following order: [``fqdn`` as String, ``ip`` as Tuple, ``min_ttl`` as Integer, ``max_ttl`` as Integer]
  """
  @spec bark({dns_fqdn, Tuple.t, Integer.t, Integer.t}) :: K9.Watchdog.bark_resp
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

  @spec digg(Tuple.t, Integer.t) :: :ok
  def digg(settings, timeout \\ 20000) do
    Logger.info  to_string(__MODULE__) <> " starting..."
    bark_loop(settings, timeout)
  end

  @spec bark_loop(Tuple.t, Integer.t) :: :ok
  defp bark_loop(settings, timeout) do
    case bark(settings) do
      {:error, reason} ->
        Logger.info to_string(reason) <> " Error occured"
      {:error, reason, message} ->
        Logger.info message <> " " <> to_string(reason)
    end

    :timer.sleep(timeout)
    bark_loop(settings, timeout)
  end
end
