defmodule WebTextAuditer.Pages do
  @url "https://chatgpt-api.shn.hk/v1/"

  def audit(webpage_url) do
    webpage_url
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Floki.parse_document!()
    |> Floki.find("p")
    |> Enum.map(&Floki.text(&1))
    |> Enum.map(&String.trim(&1))
    |> Enum.filter(&(&1 != ""))
    |> Enum.filter(&(length(String.split(&1, " ")) > 20))
  end

  def chatgpt_api_key, do: Application.get_env(:web_text_auditer, :chatgpt)[:api_key]

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
end
