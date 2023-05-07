defmodule WebTextAuditer.RequestRateLimiter do
  use GenServer

  @new_token_time_sec 20_000
  @chat_gpt_client WebTextAuditer.ChatGPT.Api

  require Logger

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    schedule_new_token()

    state = %{tokens: 0, queue: :queue.new()}
    {:ok, state}
  end

  @impl true
  def handle_cast(
        {:new_request, text_analysis_container},
        state = %{queue: queue, tokens: tokens}
      ) do
    if tokens > 0 do
      async_text_analysis(text_analysis_container)
      {:noreply, %{state | tokens: tokens - 1}}
    else
      {:noreply, %{state | queue: :queue.in(text_analysis_container, queue)}}
    end
  end

  @impl true
  def handle_info(:new_token, state = %{queue: queue}) do
    schedule_new_token()

    case :queue.out(queue) do
      {:empty, _queue} ->
        {:noreply, increase_tokens(state)}

      {{:value, text_analysis_container}, queue} ->
        async_text_analysis(text_analysis_container)
        {:noreply, %{state | queue: queue}}
    end
  end

  @impl true
  def handle_info(random, state) do
    Logger.info("#{__MODULE__} Unexpected message #{inspect(random)}")
    {:noreply, state}
  end

  defp increase_tokens(state = %{tokens: 3}), do: state
  defp increase_tokens(state = %{tokens: tokens}), do: %{state | tokens: tokens + 1}

  defp schedule_new_token(),
    do: Process.send_after(self(), :new_token, @new_token_time_sec)

  def async_text_analysis({results_receiver, pos, _texts = %{original: original_text}}) do
    Task.async(fn ->
      audited_text = @chat_gpt_client.request(original_text)
      send(results_receiver, {:audit_results, {pos, audited_text}})
    end)
  end
end
