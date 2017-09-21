defmodule Citadel.Application do
  use Application

  alias Citadel.Utils.Partitioner
  alias Citadel.{Registry, Groups, Nodes}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    redis_url = Plumbus.get_env("CITADEL_REDIS_URL", "redis://localhost", :string)
    domain    = Plumbus.get_env("CITADEL_DOMAIN", nil, :string)

    children = [
      Partitioner.worker(Registry, Citadel.Registry.Partitioner),
      Partitioner.worker(Groups, Citadel.Groups.Partitioner),
      Nodes.worker(redis_url, domain)
    ]
    opts = [strategy: :one_for_one, name: Citadel.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
