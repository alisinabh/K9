defmodule Doberman.Watchdog do
  @moduledoc """
  Watchdog is a behaviour to use different watchers in same workers
  """

  @doc "A call to watcher to check healthyness of specific paeameter(s)"
  @callback bark([]) :: {:ok, atom()} | {:error, atom()} | {:error, atom(), String.t}
end
