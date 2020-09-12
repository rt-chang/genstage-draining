defmodule GenStageDraining.Producer do
  use GenStage

  def start_link(_args) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer, {:queue.new(), 0}}
  end

  def handle_cast({:enqueue, event}, {queue, 0}) do
    queue_after_in = :queue.in(event, queue)
    {:noreply, [], {queue_after_in, 0}}
  end

  def handle_cast({:enqueue, event}, {queue, accumulated_demand}) do
    queue_after_in = :queue.in(event, queue)
    {{:value, event}, queue_after_out} = :queue.out(queue_after_in)
    {:noreply, [event], {queue_after_out, accumulated_demand - 1}}
  end

  def handle_demand(_demand, {queue, accumulated_demand}) do
    case :queue.out(queue) do
      {{:value, event}, queue_after_out} ->
        {:noreply, [event], {queue_after_out, accumulated_demand}}
      {:empty, queue} ->
        {:noreply, [], {queue, accumulated_demand + 1}}
    end
  end

  def handle_call(:drain, _from, {queue, _accumulated_demand}) do
    {:reply, queue, [], {:queue.new(), 0}}
  end
end
