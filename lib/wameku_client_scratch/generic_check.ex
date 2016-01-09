defmodule WamekuClientScratch.GenericCheck do
  use GenServer  
  require Logger

  defmodule State do
    defstruct interval: :nil
  end

  defmodule CheckMetadata do
    defstruct last_checked: :nil, exit_code: :nil, history: [], host: :nil, output: :nil, name: :nil, notifier: :nil
  end

  def start_link(check) do
    Logger.info("inside start link #{inspect(check)}")
    #spawn_link(__MODULE__, :loop, [check])
    GenServer.start_link(__MODULE__, check)
  end

  def init(check) do
    #GenServer.cast(self(), {:poll})
    {:ok, check}
  end

  def handle_cast({:poll}, state) do
    spawn_link(__MODULE__, :loop, [state])
    {:noreply, state}
  end

  def handle_cast(:run_check, state) do
    arguments  = Map.get(state, "arguments")
    check_path = Map.get(state, "path")
    name       = Map.get(state, "name")
    notifier   = Map.get(state, "notifier")
    Logger.info("Time to check #{name}")

    {:ok, hostname} = :inet.gethostname
    check_results   = Porcelain.exec(check_path, arguments)
    Logger.info("name: #{name} -- output: #{String.rstrip(check_results.out)} -- return code: #{check_results.status}")
    ## first find the check..then increment the history of the check
    check_metadata  = find_or_create_by_name(name)
    new_history     = Enum.reverse(check_metadata.history ++ [check_results.status]) |> Enum.take(20)
    new_check_metadata = %CheckMetadata{last_checked: :os.system_time(:seconds), exit_code: check_results.status, history: new_history, output: check_results.out, name: name, host: to_string(hostname), notifier: notifier}
    WamekuClientScratch.Cache.insert(:cache, {name, new_check_metadata})
    GenServer.cast(WamekuClientScratch.QueueProducer, {:publish, new_check_metadata})

    {:noreply, state}
  end

  def handle_call(:stop, _from, state) do
    Logger.info "got stop signal"
    {:stop, :normal, :ok, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    Logger.error("We went down #{inspect(ref)}")
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
    # maybe run a handle_cast or call here
    #GenSerever.cast(__MODULE__, :run_check) 
    loop(state)
  end

  def run_check(check) do
    arguments  = Map.get(check, "arguments")
    check_path = Map.get(check, "path")
    name       = Map.get(check, "name")
    notifier   = Map.get(check, "notifier")
    Logger.info("Time to check #{name}")

    {:ok, hostname} = :inet.gethostname
    check_results   = Porcelain.exec(check_path, arguments)
    Logger.info("name: #{name} -- output: #{String.rstrip(check_results.out)} -- return code: #{check_results.status}")
    ## first find the check..then increment the history of the check
    check_metadata  = find_or_create_by_name(name)
    new_history     = Enum.reverse(check_metadata.history ++ [check_results.status]) |> Enum.take(20)
    new_check_metadata = %CheckMetadata{last_checked: :os.system_time(:seconds), exit_code: check_results.status, history: new_history, output: check_results.out, name: name, host: to_string(hostname), notifier: notifier}
    WamekuClientScratch.Cache.insert(:cache, {name, new_check_metadata})
    # push results to queue
    # GenSerever.cast(WamekuClientScratch.Producer, {:pub, {output, return_code}})
    GenServer.cast(WamekuClientScratch.QueueProducer, {:publish, new_check_metadata})
  end

  defp find_or_create_by_name(name) do
    case WamekuClientScratch.Cache.lookup(:cache, name) do
      {:ok, {_name, check_metadata}} ->
        check_metadata
      :error ->
        %CheckMetadata{}
    end
  end
end
