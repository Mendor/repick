use Mix.Config

config :repick,
   config_file: System.get_env("REPICK_CONFIG_FILE") || "config.yml"

config :logger,
  level: :debug
