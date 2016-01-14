defmodule WamekuClientScratch.ParseActionsTest do
  use ExUnit.Case

  test "parse action for count gt 5 and execute command" do
    check_metadata = %{name: "count gt 5", count: 6, exit_code: 1}
    action = %{"qualifier" => "count", "condition" => "greater_than", "value" => 5, "command" => "date"}
    assert {:ok, %WamekuClientScratch.Shell.CheckResult{error: _err, output: _out, exit_code: 0}} = WamekuClientScratch.ParseActions.apply_action(action, check_metadata)
  end

  test "parse action for count lt 3 and execute command" do
    check_metadata = %{name: "count lt 3", count: 6, exit_code: 1}
    action = %{"qualifier" => "count", "condition" => "less_than", "value" => 10, "command" => "date"}
    assert {:ok, %WamekuClientScratch.Shell.CheckResult{error: _err, output: _out, exit_code: 0}} = WamekuClientScratch.ParseActions.apply_action(action, check_metadata)
  end

  test "parse action for count lt 3 and do execute command" do
    check_metadata = %{name: "count lt 3", count: 6, exit_code: 1}
    action = %{"qualifier" => "count", "condition" => "less_than", "value" => 3, "command" => "date"}
    assert {:ok, "no action applied"}
  end

  test "parse action for output uptime matches 'days'" do
    check_metadata = %{name: "match days", output: "20:56:05 up 51 days,  2:33,  9 users,  load average: 0.08, 0.17, 0.15\n", exit_code: 1}
    action = %{"qualifier" => "output", "condition" => "matches", "value" => "days", "command" => "uptime"}
    assert {:ok, %WamekuClientScratch.Shell.CheckResult{error: _err, output: _out, exit_code: 0}} = WamekuClientScratch.ParseActions.apply_action(action, check_metadata)
  end


end
