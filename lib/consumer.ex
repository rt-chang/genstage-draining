defmodule GenStageDraining.Consumer do
  use GenStage
  require Logger

  def start_link(_args) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:consumer, :ok, subscribe_to: [{GenStageDraining.Producer, max_demand: 10, min_demand: 5}]}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.debug("Terminating consumer with reason: #{reason}")
    empty_mailbox()
    queue = GenStage.call(GenStageDraining.Producer, :drain)
    drain_queue(queue)
  end

  @impl true
  def handle_events(events, _from, state) do
    for event <- events do
      Logger.debug("Event ID:#{event} has been processed")
    end
    {:noreply, [], state}
  end

  defp drain_queue(queue) do
    cond do
      :queue.is_empty(queue) ->
        Logger.debug("GenStage pipeline buffer is empty. Graceful shutdown completed")
      true ->
        {{:value, event}, queue_after_out} = :queue.out(queue)
        Logger.debug("Event ID:#{event} has been drained")
        drain_queue(queue_after_out)
    end
  end

  defp empty_mailbox() do
    case Process.info(self(), :message_queue_len) do
      {:message_queue_len, 0} ->
        nil

      _ ->
        receive do
          {:"$gen_consumer", _from, events} ->
            for event <- events do
              Logger.debug("Event ID:#{event} has been emptied from the mailbox")
            end
        end
        empty_mailbox()
    end
  end
end
