defmodule WamekuClientScratch.CheckState do
  use GenServer

  defmodule State do
    defstruct interval: :nil, name: :nil, last_checked: :nil
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__) 
  end

  def init(state) do
    {:ok, HashDict.new}
  end

  def add_check(check) do
    GenServer.call(__MODULE__, {:add, check}) 
  end 

  def all do
    GenServer.call(__MODULE__, {:all})
  end

  def handle_call({:all}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:add, check}, _from, state) do
    IO.inspect check[:name]
    # make sure check does not exist
    new_state =
    case HashDict.has_key?(state, check[:name]) do
      true ->
        HashDict.update(state, check[:name], check)
      false ->
        HashDict.put(state, check[:name], check)
    end
    IO.inspect new_state
    {:reply, new_state, state}
  end
end
