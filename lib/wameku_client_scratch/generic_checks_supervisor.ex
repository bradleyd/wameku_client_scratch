defmodule WamekuClientScratch.GenericChecksSupervisor do
  use Supervisor
  require Logger

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts) 
  end
  #  def start_link(workers, opts \\ []) do
  #    Supervisor.start_link(__MODULE__, workers, opts) 
  #  end

  def init([]) do
    #{:ok, files} = File.ls("/tmp/checks/config") 
    files  = Path.wildcard("/tmp/checks/config/*.json")
    checks = Enum.into(files, [], fn(x) -> Poison.decode!(File.read!(x)) end)
    children = 
    Enum.map(checks, fn(check) -> 
    Logger.debug("got check #{inspect(check)}")
    temp = Map.get(check, "check")
    name = Map.get(temp, "name")
    #WamekuClientScratch.GenericChecksSupervisor.start_worker(Map.get(check, "check"))
    #spawn_link(__MODULE__, :start_supervisor, [Map.get(check, "check")])
    worker(WamekuClientScratch.GenericCheck, [Map.get(check, "check")], id: name)
    end)
    #spawn_link(__MODULE__, :start_supervisor, [children])

    IO.puts "starting checks workers"
    supervise(children, strategy: :one_for_one)
  end
end
