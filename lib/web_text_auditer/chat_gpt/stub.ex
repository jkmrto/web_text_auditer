defmodule WebTextAuditer.ChatGPT.Stub do
  @behaviour WebTextAuditer.ChatGPT.Client

  def request(_text) do
    :timer.sleep(:rand.uniform(10) * 120_000)
    "stub"
  end
end
