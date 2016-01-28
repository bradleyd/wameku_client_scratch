defmodule WamekuClientScratch do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(WamekuClientScratch.Cache, [:cache]),
      worker(WamekuClientScratch.QueueProducer, []),
      supervisor(WamekuClientScratch.GenericChecksSupervisor, []),
      worker(WamekuClientScratch.WebApiServer, []),
      worker(WamekuClientScratch.Scheduler, [])
    ]

    opts = [strategy: :one_for_one, name: WamekuClientScratch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
