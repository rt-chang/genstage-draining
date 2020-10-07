import Config

config :logger,
  backends: [:console, {LoggerFileBackend, :debug}]

config :logger, :debug,
  path: "./logs/debug.log",
  level: :debug
