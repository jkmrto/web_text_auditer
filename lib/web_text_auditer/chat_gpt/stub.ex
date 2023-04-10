defmodule WebTextAuditer.ChatGPT.Stub do
  @behaviour WebTextAuditer.ChatGPT.Client
  @word "stub"

  def request(_text), do: "stub"
end
