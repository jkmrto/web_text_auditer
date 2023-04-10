defmodule WebTextAuditer.Repo do
  use Ecto.Repo,
    otp_app: :web_text_auditer,
    adapter: Ecto.Adapters.Postgres
end
