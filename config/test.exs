import Config

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
