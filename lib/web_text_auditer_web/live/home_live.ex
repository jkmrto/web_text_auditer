defmodule WebTextAuditerWeb.Live.HomeLive do
  use WebTextAuditerWeb, :live_view

  # @chat_gpt_client WebTextAuditer.ChatGPT.Stub
  @chat_gpt_client WebTextAuditer.ChatGPT.Api
  @task_timeout 60_000

  def mount(_params, _session, socket) do
    form = %{"webpage" => "http://localhost:4000/"}

    {:ok, assign(socket, audited_texts: %{}, form: form, show_spinner: false)}
  end

  def handle_event("audit", %{"webpage" => webpage}, socket) do
    texts = WebTextAuditer.Pages.audit(webpage)

    texts_container = Enum.map(texts, fn text -> %{original: text, audited: nil} end)

    texts_container =
      texts_container
      |> Enum.with_index()
      |> Enum.into(%{}, fn {string, pos} -> {pos, string} end)

    results_receiver = self()
    Task.async(fn -> async_audit(texts_container, results_receiver) end)

    {:noreply, assign(socket, show_spinner: true, audited_texts: texts_container)}
  end

  def handle_info(
        {:audit_results, {pos, audited_text}},
        socket = %{assigns: %{audited_texts: texts_container}}
      ) do

    text_container = Map.get(texts_container, pos)
    text_container = %{text_container | audited: audited_text}
    texts_container = Map.put(texts_container, pos, text_container)
    {:noreply, assign(socket, audited_texts: texts_container, show_spinner: false)}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, socket) do
    {:noreply, socket}
  end

  def handle_info({_ref, _message}, socket) do
    {:noreply, socket}
  end

  def async_audit(texts_container, results_receiver) do
    texts_container
    |> Enum.each(fn {pos, %{original: original_text}} ->
      Task.async(fn ->
        audited_text = @chat_gpt_client.request(original_text)
        send(results_receiver, {:audit_results, {pos, audited_text}})
      end)
    end)
  end

  def spinner(assigns) do
    ~H"""
    <div
      class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]"
      role="status"
    >
      <span class="!absolute !-m-px !h-px !w-px !overflow-hidden !whitespace-nowrap !border-0 !p-0 ![clip:rect(0,0,0,0)]">
        Loading...
      </span>
    </div>
    """
  end
end
