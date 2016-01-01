defmodule WamekuClientScratch.GenericCheck do
  use GenServer  
  require Logger

  @checks_directory "/tmp/"

  defmodule State do
    defstruct interval: :nil
  end

  defmodule CheckMetadata do
    defstruct last_checked: :nil, exit_code: :nil
  end

  def start_link(check) do
    Logger.info("inside start link #{inspect(check)}")
    GenServer.start_link(__MODULE__, check)
  end

  def init(check) do
    GenServer.cast(self(), {:poll})
    {:ok, check}
  end

  def handle_cast({:poll}, state) do
    spawn(__MODULE__, :loop, [state])
    {:noreply, state}
  end

  def handle_call(:stop, _from, state) do
    Logger.info "got stop signal"
    {:stop, :normal, :ok, state}
  end

def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end
  def handle_info(msg, state) do
    Logger.debug("Got #{msg}") 
    {:noreply, state}
  end

  def loop(state) do
    interval = Map.get(state, "interval")
    Logger.debug("Sleeping for #{interval * 1000} milliseconds")
    :timer.sleep(interval * 1000)
    run_check(state)
    loop(state)
  end

  def run_check(check) do
    arguments  = Map.get(check, "arguments")
    check_path = Map.get(check, "path")
    name       = Map.get(check, "name")
    Logger.info("About to run #{name} with #{check_path}")
    {output, return_code} = System.cmd("sh", [check_path] ++ arguments)
    Logger.debug("output: #{String.rstrip(output)} exit code: #{return_code}")
    WamekuClientScratch.Cache.insert(:cache, {name, %CheckMetadata{last_checked: :os.system_time(:seconds), exit_code: return_code}})
    # push results to queue
    # GenSerever.cast(WamekuClientScratch.Producer, {:pub, {output, return_code}})
  end
end
