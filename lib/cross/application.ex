defmodule Cross.Application do
  use Application

  def start(_type, _args),
    do: Supervisor.start_link(children(), opts())

  defp children do
    import Supervisor.Spec
    [
      Cross.Endpoint,
      worker(Storage, [], restart: :transient)
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: Cross.Supervisor
    ]
  end
end

