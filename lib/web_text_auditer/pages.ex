defmodule WebTextAuditer.Pages do
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
end
