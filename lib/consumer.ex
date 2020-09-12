defmodule GenStageDraining.Consumer do
  use GenStage

  def start_link(_args) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:consumer, :ok, subscribe_to: [{GenStageDraining.Producer, max_demand: 1}]}
  end

  def terminate(reason, _state) do
    IO.puts("Terminating consumer with reason: #{reason}")
    queue = GenStage.call(GenStageDraining.Producer, :drain)
    drain_queue(queue)

    receive do
      {:DOWN, _ref, :process, _obj, _reason} ->
        :ok
    end
  end

  def handle_events(events, _from, state) do
    for event <- events do
      :timer.sleep(100)
      IO.puts("#{event} has been handled")
    end
    {:noreply, [], state}
  end

  defp drain_queue(queue) do
    cond do
      :queue.is_empty(queue) ->
        IO.puts("GenStage pipeline buffer is empty. Graceful shutdown completed")
      true ->
        {{:value, event}, queue_after_out} = :queue.out(queue)
        IO.puts("Event ID:#{event} has been drained and handled")
        drain_queue(queue_after_out)
    end
  end
end
