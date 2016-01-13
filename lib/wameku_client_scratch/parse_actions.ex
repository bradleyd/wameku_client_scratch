defmodule WamekuClientScratch.ParseActions do
  require Logger

  def apply_action(action=%{"qualifier" => "count", "condition" => "greater_than", "value" => value, "command" => command}, check_metadata) do
    
    actual = Map.get(check_metadata, :count)
    results = 
    if actual > value && check_metadata.exit_code != 0 do
      Logger.info("taking action for #{action["name"]}")
      Porcelain.exec(command, [])
    else
      "action not applied"
    end
    {:ok, results}
  end
  def apply_action(action=%{"qualifier" => "count", "condition" => "less_than", "value" => value, "command" => command}, check_metadata) do
    
    actual = Map.get(check_metadata, :count)
    results =
    if actual < value && check_metadata.exit_code != 0 do
      Logger.info("taking action for #{action["name"]}")
      Porcelain.exec(command, [])
    else
      "action not applied"
    end
    {:ok, results}
  end

end
