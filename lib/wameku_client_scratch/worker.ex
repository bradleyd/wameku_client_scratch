defmodule WamekuClientScratch.Worker do
  require Logger

  defmodule CheckMetadata do
    defstruct count: 0, actions: [], last_checked: :nil, exit_code: :nil, history: [], host: :nil, output: :nil, name: :nil, notifier: []
  end

  def start_link(check) do
    pid = spawn_link(__MODULE__, :loop, [check])
    {:ok, pid}
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
    notifier   = Map.get(check, "notifier", [])
    actions    = Map.get(check, "actions", [])
    Logger.info("Time to check #{name}")

    {:ok, hostname} = :inet.gethostname
    check_results   = Porcelain.exec(check_path, arguments)
    Logger.info("name: #{name} -- output: #{String.rstrip(check_results.out)} -- return code: #{check_results.status}")
    ## first find the check..then increment the history of the check
    check_metadata  = find_or_create_by_name(name)
    new_history     = update_history(check_metadata.history, check_results.status)
    new_check_metadata = %CheckMetadata{last_checked: :os.system_time(:seconds), exit_code: check_results.status, history: new_history, output: check_results.out, name: name, host: to_string(hostname), notifier: notifier, actions: actions, count: increment_count(check_results.status, check_metadata.count)}
    WamekuClientScratch.Cache.insert(:cache, {name, new_check_metadata})
    take_action(actions, new_check_metadata)
    # push results to queue
    GenServer.cast(WamekuClientScratch.QueueProducer, {:publish, new_check_metadata})
  end

  # This is awful but the idea what counts
  defp take_action([], check_status), do: false
  defp take_action([h|t], check_status) do
    name = Map.get(h, "name")
    qualifier = Map.get(h, "qualifier")
    command = Map.get(h, "command")
    check_variable = hd(qualifier)
    check_condition = List.last(qualifier)

    # find key and value in check_status
    actual_variable = Map.get(check_status, String.to_atom(check_variable))
    Logger.info(inspect(actual_variable))
    # We must have a non-zero exit_code to run
     
    if actual_variable >= check_condition && check_status.exit_code != 0 do
      Porcelain.exec(command, [])
    end
  end

  defp find_or_create_by_name(name) do
    case WamekuClientScratch.Cache.lookup(:cache, name) do
      {:ok, {_name, check_metadata}} ->
        check_metadata
      :error ->
        %CheckMetadata{}
    end
  end

  defp increment_count(status_code, count) do
    case status_code do
      0 -> 0
      1 -> count + 1
      2 -> count + 1
      _large -> count
    end
  end

  defp update_history(old, new) do
    Enum.reverse(old ++ [new]) |> Enum.take(20)
  end

end
