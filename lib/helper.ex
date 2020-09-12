defmodule GenStageDraining.Helper do
  alias GenStageDraining.Producer
  def enqueue_n_events(n) do
    1..n
    |> Enum.map(fn num -> GenStage.cast(Producer, {:enqueue, num}) end)
  end
end
