defmodule WamekuClientScratch.CheckRunner do
  use GenServer  
  require Logger

  @checks_directory "/tmp/"

  defmodule State do
    defstruct last_checked: :nil
  end

  defmodule CheckMetadata do
    defstruct last_checked: :nil, exit_code: :nil
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
    {output, return_code} = System.cmd("sh", [check] ++ arguments)
    Logger.info(String.rstrip(output))
    Logger.info return_code 
    WamekuClientScratch.Cache.insert(:cache, {name, %CheckMetadata{last_checked: :os.system_time(:seconds), exit_code: return_code}})
    # push results to queue
    # GenSerever.cast(WamekuClientScratch.Producer, {:pub, {output, return_code}})
    {:noreply, state}
  end
end
