defmodule WamekuClientScratch.Scheduler do
  use GenServer  
  require Logger

  defmodule State do
    defstruct config: :nil, queue_name: :nil
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init([]) do
    GenServer.cast(__MODULE__, {:poll})
    {:ok, []}
  end

  def handle_cast({:poll}, state) do
    spawn_link(__MODULE__, :loop, [state])
    {:noreply, state}
  end

  def loop(state) do
    Path.wildcard("/tmp/checks/config/*.json")
    |> Enum.into([], fn(x) -> Poison.decode!(File.read!(x)) end)
    |> Enum.each(fn(check) ->
      WamekuClientScratch.GenericChecksSupervisor.start_child(Map.get(check, "check"))
    end)
  end
end
