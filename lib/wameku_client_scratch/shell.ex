defmodule WamekuClientScratch.Shell  do
  
  defmodule CheckResult do
    defstruct exit_code: :nil, output: :nil, error: :nil 
  end

  def run(command, args) do
    result = Porcelain.exec(command, args)
    %CheckResult{exit_code: result.status, output: result.out, error: result.err}
  end
end
