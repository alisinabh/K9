defmodule K9.Watchdog do
  @moduledoc """
  Watchdog is a behaviour to use different watchers in same workers
  """
  
  @type bark_resp :: {:ok, atom()} | {:error, atom()} | {:error, atom(), String.t}

  @doc "A call to watcher to check healthyness of specific paeameter(s)"
  @callback bark(Tuple.t) :: bark_resp
end
