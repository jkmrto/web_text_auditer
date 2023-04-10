defmodule WebTextAuditer.ChatGPT.Client do
  @callback request(text :: String.t()) :: String.t()
end
