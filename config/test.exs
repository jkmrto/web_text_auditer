import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :web_text_auditer, WebTextAuditer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "web_text_auditer_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :web_text_auditer, WebTextAuditerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "DRN3duwpWiBrP94wGGeMQuxwNXkE2P74yNb9aWIU/3+I5AWrFGv4o6G4VGSqP366",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
