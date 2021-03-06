defmodule Knine.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = Application.get_env(:knine, :dogs) |> extract_dogs
    # [
    #   # Starts a worker by calling: Knine.Worker.start_link(arg1, arg2, arg3)
    #   worker(Knine.DnsWatchdog, [{'alisinabh.com', {217,218,155,155}}]),
    # ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Knine.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp extract_dogs(dogs) do
    extract_dogs(dogs, [])
  end

  defp extract_dogs([{id, dog_type, dog_bones} | tail_dogs], acc) do
    extract_dogs(tail_dogs, [worker(Task, [Knine.Watchdog, :digg, [dog_type | dog_bones]], id: id) | acc])
  end

  defp extract_dogs([], acc) do
     acc
  end
end
