defmodule WebTextAuditer.ChatGPT.Api do
  @behaviour WebTextAuditer.ChatGPT.Client

  @url "https://chatgpt-api.shn.hk/v1/"

  def request(text) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{chatgpt_api_key()}"}
    ]

    body = %{
      "model" => "gpt-3.5-turbo",
      "messages" => [
        %{
          "role" => "user",
          "content" =>
            "Could you improve this text? Please respect the ideas on the text: \n #{text}"
        }
      ]
    }

    resp = HTTPoison.post(@url, Jason.encode!(body), headers, recv_timeout: 60_000)

    {:ok, %HTTPoison.Response{status_code: 200, body: resp_body}} = resp

    resp_body
    |> Jason.decode!()
    |> Map.get("choices")
    |> List.first()
    |> Map.get("message")
    |> Map.get("content")
  end

  defp chatgpt_api_key, do: Application.get_env(:web_text_auditer, :chatgpt)[:api_key]
end
