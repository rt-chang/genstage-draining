defmodule GenStageDraining.Application do
  use Application

  def start(_type, _args) do
    children = [
      GenStageDraining.Producer,
      Supervisor.child_spec(GenStageDraining.Consumer, shutdown: 30_000)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
