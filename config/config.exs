use Mix.Config

config :cross, Cross.Endpoint, port: 4000

import_config "#{Mix.env()}.exs"
