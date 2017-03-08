defmodule Knine.Buzzer do
  @moduledoc """
  Buzzer's are modules which handles bark responses.
  A buzzer may do what it think is neccessary to do on an specific event (e.g: send an email). Every watchdog can only have one buzzer.
  """

  @callback buzz(Knine.Watchdog.bark_resp) :: :ok | :error

  defmacro __using__(_) do
    quote do
      @behaviour Knine.Buzzer
    end
  end
end

defmodule Knine.LoggerBuzzer do
  @moduledoc """
  A buzzer which writes debug logs.
  """

  require Logger
  use Knine.Buzzer

  def buzz({severity, msg}) do
    logger_type = case severity do
      :low -> &Logger.info/1
      :moderate -> &Logger.debug/1
      :major -> &Logger.warn/1
      :critical -> &Logger.error/1
    end

    cond do
      msg != nil ->
        logger_type.(msg)
      true ->
        :ok
    end
  end
end
