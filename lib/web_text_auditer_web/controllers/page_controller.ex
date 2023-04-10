# defmodule AuditedText do
#  defstruct [:original, :audited]
# end

defmodule WebTextAuditerWeb.PageController do
  use WebTextAuditerWeb, :controller

  @task_timeout 60_000

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    texts = WebTextAuditer.Pages.audit("https://www.jkmrto.dev/resume")

    Kernel.length(texts) |> IO.inspect(label: "texts")

    audited_texts =
      texts
      |> Enum.map(fn text ->
        Task.async(fn ->
          audited_text = WebTextAuditer.Pages.request(text)
          %{original: text, audited: audited_text}
        end)
      end)
      |> Enum.map(fn task -> Task.await(task, @task_timeout) end)

    render(conn, :home, audited_texts: audited_texts, layout: false)
  end
end

# curl https://chatgpt-api.shn.hk/v1/ \
#  -H 'Content-Type: application/json'   -H "Authorization: Bearer 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" \
#  -d '{
#  "model": "gpt-3.5-turbo",
#  "messages": [{"role": "user", "content": "Hello, how are you?"}]
# }'
