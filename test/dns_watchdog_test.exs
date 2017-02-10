defmodule DnsWatchdogTest do
  use ExUnit.Case
  require K9.DnsWatchdog

  test "resolve method works correctly?" do
    assert {:ok, {_, _, _, _}, _} = K9.DnsWatchdog.resolve('google.com')
  end

  test "dns watchdog works on match?" do
    {:ok, _} = K9.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 10, 800000})
  end

  test "dns watchdog works on unmatch?" do
    case K9.DnsWatchdog.bark({'google-public-dns-a.google.com', {4,2,2,4}, 10, 800000}) do
      {:ok, _} -> assert false
      _ -> assert 1==1
    end
  end

  test "dns watchdog works on min ttl?" do
    case K9.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 700000, 800000}) do
      {:ok, _} -> assert false
      _ -> assert 1==1
    end
  end

  test "dns watchdog works on max ttl?" do
    case K9.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 10, 1000}) do
      {:ok, _} -> assert false
      _ -> assert 1==1
    end
  end
end
