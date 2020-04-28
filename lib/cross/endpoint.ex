defmodule Cross.Endpoint do
  use Plug.Router

  @name __MODULE__
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:text],
    pass: ["json/application"]
    )

  plug(:dispatch)

  forward("/", to: Cross.Router)

  @spec child_spec(any) :: %{id: Cross.Endpoint, start: {Cross.Endpoint, :start_link, [...]}}
  def child_spec(opts) do
    %{
      id: @name,
      start: {@name, :start_link, [opts]}
    }
  end

  def start_link(_opts), do: Plug.Cowboy.http(@name, [])

  end
