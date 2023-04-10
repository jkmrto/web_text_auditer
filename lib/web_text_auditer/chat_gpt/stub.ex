defmodule WebTextAuditer.ChatGPT.Stub do
  @behaviour WebTextAuditer.ChatGPT.Client

  def request(_text) do
    :timer.sleep(2_000)
    "stub"
  end
end
