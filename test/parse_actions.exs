defmodule WamekuClientScratch.ParseActionsTest do
  use ExUnit.Case

  test "parse action for count gt 5 and execute command" do
    check_metadata = %{count: 6, exit_code: 1}
    action = %{"qualifier" => "count", "condition" => "greater_than", "value" => 5, "command" => "date"}
    assert {:ok, %Porcelain.Result{err: _err, out: _out, status: 0}} = WamekuClientScratch.ParseActions.apply_action(action, check_metadata)
  end
  test "parse action for count lt 3 and execute command" do
    check_metadata = %{count: 6, exit_code: 1}
    action = %{"qualifier" => "count", "condition" => "less_than", "value" => 10, "command" => "date"}
    assert {:ok, %Porcelain.Result{err: _err, out: _out, status: 0}} = WamekuClientScratch.ParseActions.apply_action(action, check_metadata)
  end
  test "parse action for count lt 3 and execute command" do
    check_metadata = %{count: 6, exit_code: 1}
    action = %{"qualifier" => "count", "condition" => "less_than", "value" => 3, "command" => "date"}
    assert {:ok, "no action applied"}
  end


end
