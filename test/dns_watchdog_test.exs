defmodule DnsWatchdogTest do
  use ExUnit.Case
  require K9.Watchdog.DnsWatchdog
  import K9Test.Assertion

  test "resolve method works correctly?" do
    assert {:ok, {_, _, _, _}, _} = K9.Tools.DnsTools.resolve('google.com')
  end

  test "dns watchdog works on match?" do
    assert {:ok, _} = K9.Watchdog.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 10, 800000})
  end

  test "dns watchdog works on unmatch?" do
    refute_match {:ok, _} = K9.Watchdog.DnsWatchdog.bark({'google-public-dns-a.google.com', {4,2,2,4}, 10, 800000})
  end

  test "dns watchdog works on min ttl?" do
    refute_match {:ok, _} = K9.Watchdog.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 700000, 800000})
  end

  test "dns watchdog works on max ttl?" do
    refute_match {:ok, _} = K9.Watchdog.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 10, 1000})
  end
end
