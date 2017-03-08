defmodule Knine.Watchdog do
  @moduledoc """
  Watchdog is a behaviour to use different watchers in same workers
  """
  require Logger

  @type bark_resp :: {:low, String.t} | {:moderate, String.t} | {:major, String.t} | {:critical, String.t}

  @doc "A call to watcher for checking healthyness of specific parameters(s)"
  @callback bark(Tuple.t) :: bark_resp

  defmacro __using__(_) do
    quote do
      @behaviour Knine.Watchdog
    end
  end

  @spec digg(atom(), Tuple.t, Integer.t, Tuple.t) :: :ok
  def digg(module, settings, interval \\ 20000, buzzer_info) do
    Logger.info "#{to_string(module)} starting..."
    bark_loop(module, settings, interval, buzzer_info)
    # TODO: ability to add multiple buzzers on a single watchdog.
    # Maybe add watch groups?
  end

  @spec bark_loop(atom(), Tuple.t, Integer.t, Tuple.t) :: :ok
  defp bark_loop(module, settings, interval, {buzzer, buzz_settings}) do
    bark_result = module.bark(settings)
    buzzer.buzz(bark_result)

    :timer.sleep(interval)
    bark_loop(module, settings, interval)
  end

  def register_dog() do

  end
end
