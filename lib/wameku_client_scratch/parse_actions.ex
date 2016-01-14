defmodule WamekuClientScratch.ParseActions do
  require Logger

  def apply_action(action=%{"apply_on_error" => false, "qualifier" => "count", "condition" => "greater_than", "value" => value, "command" => command}, check_metadata) do
    
    actual = Map.get(check_metadata, :count)
    results = 
    if actual > value do
      Logger.info("taking action for #{check_metadata.name}")
      WamekuClientScratch.Shell.run(command, [])
    else
      "action not applied"
    end
    {:ok, results}
  end
  def apply_action(action=%{"qualifier" => "count", "condition" => "greater_than", "value" => value, "command" => command}, check_metadata) do
    
    actual = Map.get(check_metadata, :count)
    results = 
    if actual > value && check_metadata.exit_code != 0 do
      Logger.info("taking action for #{check_metadata.name}")
      WamekuClientScratch.Shell.run(command, [])
    else
      "action not applied"
    end
    {:ok, results}
  end
  def apply_action(action=%{"apply_on_error" => false, "qualifier" => "count", "condition" => "less_than", "value" => value, "command" => command}, check_metadata) do
    
    actual = Map.get(check_metadata, :count)
    results =
    if actual < value do
      Logger.info("taking action for #{check_metadata.name}")
      WamekuClientScratch.Shell.run(command, [])
    else
      "action not applied"
    end
    {:ok, results}
  end
  def apply_action(action=%{"qualifier" => "count", "condition" => "less_than", "value" => value, "command" => command}, check_metadata) do
    
    actual = Map.get(check_metadata, :count)
    results =
    if actual < value && check_metadata.exit_code != 0 do
      Logger.info("taking action for #{check_metadata.name}")
      WamekuClientScratch.Shell.run(command, [])
    else
      "action not applied"
    end
    {:ok, results}
  end
  def apply_action(action=%{"apply_on_error" => true, "qualifier" => "output", "condition" => "matches", "value" => value, "command" => command}, check_metadata) do
    
    actual  = Map.get(check_metadata, :output)
    regex   = Regex.compile!(value)
    results =
    if Regex.match?(regex, actual) && check_metadata.exit_code != 0 do
      Logger.info("taking action for #{check_metadata.name}")
      WamekuClientScratch.Shell.run(command, [])
    else
      "action not applied"
    end
    {:ok, results}
  end
  def apply_action(action=%{"apply_on_error" => false, "qualifier" => "output", "condition" => "matches", "value" => value, "command" => command}, check_metadata) do
    
    actual  = Map.get(check_metadata, :output)
    regex   = Regex.compile!(value)
    results =
    if Regex.match?(regex, actual) do
      Logger.info("taking action for #{check_metadata.name}")
      WamekuClientScratch.Shell.run(command, [])
    else
      "action not applied"
    end
    {:ok, results}
  end

end
