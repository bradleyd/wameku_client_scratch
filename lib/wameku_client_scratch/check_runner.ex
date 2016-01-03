defmodule WamekuClientScratch.CheckRunner do
  use GenServer  
  require Logger

  @checks_directory "/tmp/"

  defmodule State do
    defstruct last_checked: :nil
  end

  defmodule CheckMetadata do
    defstruct last_checked: :nil, exit_code: :nil, history: [], host: :nil
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  def start() do
    start_link([])
  end

  def init([]) do
    # call cast on self to loop and fetch messages
    #aws_key = System.get_env("AWS_ACCESS_KEY_ID")
    #secret_key = System.get_env("AWS_SECRET_ACCESS_KEY")
    #aws_url = System.get_env("AWS_URL") || "sqs.us-west-2.amazonaws.com"
    #queue_name = System.get_env("SENSOR_QUEUE_NAME") || "sensorqs-dev-queue"
    #config = :erlcloud_sqs.new(String.to_char_list(aws_key), String.to_char_list(secret_key), String.to_char_list(aws_url))

    #{:ok, %State{config: config, queue_name: queue_name}}
    {:ok, []}
  end

  def handle_cast({:check, check_path}, state) do
    arguments = Map.get(check_path, "arguments")
    check     = Map.get(check_path, "path")
    name      = Map.get(check_path, "name")
    #{output, return_code} = System.cmd("sh", [check] ++ arguments)
    check_results = Porcelain.exec(check, arguments)
    Logger.info("name: #{name} -- output: #{String.rstrip(check_results.out)} -- return code: #{check_results.status}")
    ## first find the check..then increment the history of the check
    check_metadata = find_or_create_by_name(name)
    new_history = Enum.reverse(check_metadata.history ++ [check_results.status]) |> Enum.take(20)
    new_check_metadata = %CheckMetadata{last_checked: :os.system_time(:seconds), exit_code: check_results.status, history: new_history }
    Logger.info(inspect(new_check_metadata))
    WamekuClientScratch.Cache.insert(:cache, {name, new_check_metadata})
    # push results to queue
    # GenSerever.cast(WamekuClientScratch.Producer, {:pub, {name, output, return_code}})
    {:noreply, state}
  end

  defp find_or_create_by_name(name) do
    case WamekuClientScratch.Cache.lookup(:cache, name) do
      {:ok, {name, check_metadata}} ->
        check_metadata
      :error ->
        %CheckMetadata{}
    end
  end
end
