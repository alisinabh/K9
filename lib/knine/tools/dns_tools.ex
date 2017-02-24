defmodule Knine.Tools.DnsTools do
  @moduledoc """
  Dns resolve tools
  """

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
end
