defmodule WamekuClientScratch.GenericChecksSupervisor do
  import Supervisor.Spec, warn: false
  require Logger

  def start_link(args \\ []) do
    children = [ worker(WamekuClientScratch.Worker, [])]
    opts = [
      strategy: :simple_one_for_one, name: WamekuClientScratch.GenericChecksSupervisor.Supervisor
    ]
    Supervisor.start_link(children, opts)
  end

  def start_child(check) do
    Logger.debug("Starting child worker for #{inspect(check)}")
    Supervisor.start_child(WamekuClientScratch.GenericChecksSupervisor.Supervisor, [check])
  end

end
