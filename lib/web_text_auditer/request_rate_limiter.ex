defmodule WebTextAuditer.RequestRateLimiter do
  use GenServer

  @new_token_time_sec 20_000

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
  def handle_cast({:new_request, element}, state = %{queue: queue, tokens: tokens}) do
    if tokens > 0 do
      IO.inspect(element, label: "this is consumed !!!")
      {:noreply, %{state | tokens: tokens - 1}}
    else
      {:noreply, %{state | queue: :queue.in(element, queue)}}
    end
  end

  @impl true
  def handle_info(:new_token, state = %{queue: queue}) do
    schedule_new_token()

    if :queue.is_empty(queue) do
      {:noreply, increase_tokens(state)}
    else
      {element, queue} = :queue.out(queue)
      IO.inspect(element, label: "this is consumed !!!")
      {:noreply, %{state | queue: queue}}
    end
  end

  defp increase_tokens(state = %{tokens: 3}), do: state
  defp increase_tokens(state = %{tokens: tokens}), do: %{state | tokens: tokens + 1}

  defp schedule_new_token(),
    do: Process.send_after(self(), :new_token, @new_token_time_sec)
end
