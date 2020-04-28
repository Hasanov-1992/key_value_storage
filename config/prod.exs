use Mix.Config
config :cross, Cross.Endpoint,
port: "PORT" |> System.get_env() |> String.to_integer()
