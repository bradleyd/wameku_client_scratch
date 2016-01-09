defmodule WamekuClientScratch.Scheduler do
  use GenServer  
  require Logger

  @checks_directory "/tmp/"

  defmodule State do
    defstruct config: :nil, queue_name: :nil
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  def start() do
    start_link([])
  end

  def init([]) do
    GenServer.cast(__MODULE__, {:poll})
    {:ok, []}
  end

  def handle_cast({:check, check_path}, state) do
    {output, return_code} = System.cmd("sh", [check_path])
    # push results to queue
    # GenSerever.cast(WamekuClientScratch.Producer, {:pub, {output, return_code}})
    {:noreply, state}
  end

  def handle_cast({:poll}, state) do
    spawn_link(__MODULE__, :loop, [state])
    {:noreply, state}
  end

  def loop(state) do
    import Supervisor.Spec, warn: false
    files = Path.wildcard("/tmp/checks/config/*.json")
    checks = Enum.into(files, [], fn(x) -> Poison.decode!(File.read!("/tmp/checks/config/" <> x)) end)
    children = 
    Enum.map(checks, fn(check) -> 
    Logger.debug("got check #{inspect(check)}")
    temp = Map.get(check, "check")
    name = Map.get(temp, "name")
    #WamekuClientScratch.GenericChecksSupervisor.start_worker(Map.get(check, "check"))
    #spawn_link(__MODULE__, :start_supervisor, [Map.get(check, "check")])
    worker(WamekuClientScratch.GenericCheck, [Map.get(check, "check")], id: name)
    end)
    spawn_link(__MODULE__, :start_supervisor, [children])
  end

  def start_supervisor(workers) do
    #WamekuClientScratch.GenericChecksSupervisor.start_worker(workers)
    {:ok, pid} = WamekuClientScratch.GenericChecksSupervisor.start_link(workers, [name: WamekuClientScratch.GenericChecksSupervisor])
    IO.inspect pid
    IO.inspect Process.monitor(pid)
  end
end
