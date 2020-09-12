defmodule GenStageDraining.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      GenStageDraining.Producer,
      Supervisor.child_spec(GenStageDraining.Consumer, shutdown: 10_000)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
