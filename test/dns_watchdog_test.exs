defmodule DnsWatchdogTest do
  use ExUnit.Case
  require Knine.Watchdog.DnsWatchdog
  import KnineTest.Assertion

  test "resolve method works correctly?" do
    assert {:ok, {_, _, _, _}, _} = Knine.Tools.DnsTools.resolve('google.com')
  end

  test "dns watchdog works on match?" do
    assert {:ok, _} = Knine.Watchdog.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 10, 800000})
  end

  test "dns watchdog works on unmatch?" do
    refute_match {:ok, _} = Knine.Watchdog.DnsWatchdog.bark({'google-public-dns-a.google.com', {4,2,2,4}, 10, 800000})
  end

  test "dns watchdog works on min ttl?" do
    refute_match {:ok, _} = Knine.Watchdog.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 700000, 800000})
  end

  test "dns watchdog works on max ttl?" do
    refute_match {:ok, _} = Knine.Watchdog.DnsWatchdog.bark({'google-public-dns-a.google.com', {8,8,8,8}, 10, 1000})
  end
end
