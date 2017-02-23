defmodule K9.Watchdog do
  @moduledoc """
  Watchdog is a behaviour to use different watchers in same workers
  """

  @type bark_resp :: :ok | {:ok, atom()} | {:ok, atom(), String.t} | {:error, atom()} | {:error, atom(), String.t}

  @doc "A call to watcher to check healthyness of specific paeameter(s)"
  @callback bark(Tuple.t) :: bark_resp

  @doc "``digger/2`` Implementation for Watchdogs"
  defmacro __using__(_) do
    quote do
      require Logger

      @behaviour K9.Watchdog

      @spec digg(Tuple.t, Integer.t) :: :ok
      def digg(settings, timeout \\ 20000) do
        Logger.info  to_string(__MODULE__) <> " starting..."
        bark_loop(settings, timeout)
      end

      @spec bark_loop(Tuple.t, Integer.t) :: :ok
      defp bark_loop(settings, timeout) do
        case bark(settings) do
          :ok ->
            Logger.debug to_string(__MODULE__) <> " Returned OK!"
          {:ok, reason} ->
            Logger.debug to_string(__MODULE__) <> " Returned OK: " <> to_string(reason)
          {:ok, reason, message} ->
            Logger.debug to_string(__MODULE__) <> " Returned OK: " <> to_string(reason) <> " And says: " <> message
          {:error, reason} ->
            Logger.info to_string(reason) <> " Error occured"
          {:error, reason, message} ->
            Logger.info message <> " " <> to_string(reason)
        end

        :timer.sleep(timeout)
        bark_loop(settings, timeout)
      end
    end
  end
end
