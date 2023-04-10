defmodule WebTextAuditerWeb.Live.HomeLive do
  use WebTextAuditerWeb, :live_view

  #  @chat_gpt_client WebTextAuditer.ChatGPT.Stub
  @chat_gpt_client WebTextAuditer.ChatGPT.Api
  @task_timeout 60_000

  def render(assigns) do
    ~H"""
    <.form
      class="p-5 mx-10 mb-10 w-10/12 border border-gray-400 rounded-lg"
      for={@form}
      phx-submit="audit"
    >
      <div class="ml-5 flex flex-row">
        <.input name="webpage" type="text" value={@form[:webpage]} field={@form[:webpage]} />
        <button class="mx-5 bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full">
          Audit
        </button>
      </div>
    </.form>

    <div>
      <%= for audited_text  <- @audited_texts do %>
        <div class="m-3 flex flex-row border border-gray-100">
          <p class="p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-400 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
            <%= audited_text.original %>
          </p>

          <p class="ml-3 p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-400 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
            <%= audited_text.audited %>
          </p>
        </div>
      <% end %>
    </div>

    <%= if @show_spinner do %>
      <div
        class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]"
        role="status"
      >
        <span class="!absolute !-m-px !h-px !w-px !overflow-hidden !whitespace-nowrap !border-0 !p-0 ![clip:rect(0,0,0,0)]">
          Loading...
        </span>
      </div>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    form = %{"webpage" => "http://localhost:4000/"}

    {:ok, assign(socket, audited_texts: [], form: form, show_spinner: false)}
  end

  def handle_event("audit", %{"webpage" => webpage}, socket) do
    IO.inspect("audit request for #{webpage} has been received")

    Task.async(fn -> async_audit(webpage, self()) end)

    {:noreply, assign(socket, show_spinner: true)}
  end

  def handle_info({_ref, {:audit_results, audited_texts}}, socket) do
    {:noreply, assign(socket, audited_texts: audited_texts, show_spinner: false)}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, socket) do
    {:noreply, socket}
  end

  def async_audit(webpage, results_receiver) do
    texts = WebTextAuditer.Pages.audit(webpage)

    audited_texts =
      texts
      |> Enum.map(fn text ->
        Task.async(fn ->
          audited_text = @chat_gpt_client.request(text)
          %{original: text, audited: audited_text}
        end)
      end)
      |> Enum.map(fn task -> Task.await(task, @task_timeout) end)

    send(results_receiver, {:audit_results, audited_texts})
  end
end
