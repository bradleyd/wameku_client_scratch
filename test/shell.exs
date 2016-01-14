defmodule WamekuClientScratch.ShellTest do
  use ExUnit.Case

  test "Returns a CheckResult struct when command executed" do
    assert %WamekuClientScratch.Shell.CheckResult{exit_code: 0, output: _output, error: _error } = WamekuClientScratch.Shell.run("date", [])
  end
end
