defmodule GenStageDraining.Producer do
  use GenStage
  require Logger
  
  def start_link(_args) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:producer, {:queue.new(), 0}}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.debug("Terminating producer with reason: #{reason}")
  end

  @impl true
  def handle_cast({:enqueue, event}, {queue, accumulated_demand}) do
    queue_after_in = :queue.in(event, queue)
    dispatch_events(queue_after_in, accumulated_demand, [])
  end

  @impl true
  def handle_demand(new_demand, {queue, accumulated_demand}) do
    dispatch_events(queue, new_demand + accumulated_demand, [])
  end

  @impl true
  def handle_call(:drain, _from, {queue, _accumulated_demand}) do
    {:reply, queue, [], {:queue.new(), 0}}
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, event}, queue_after_out} ->
        dispatch_events(queue_after_out, demand - 1, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
