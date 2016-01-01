defmodule WamekuClientScratch.GenericChecksSupervisor do
 use Supervisor
 def start_link(workers, opts \\ []) do
    IO.inspect Supervisor.start_link(__MODULE__, workers, opts) 
  end

  def init(workers) do
    IO.puts "starting checks workers"
    supervise(workers, strategy: :one_for_one)
  end
end
