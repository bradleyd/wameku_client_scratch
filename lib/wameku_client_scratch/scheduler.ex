defmodule WamekuClientScratch.Scheduler do
  use GenServer  
  require Logger

  @checks_directory "/tmp/"

  defmodule State do
    defstruct config: :nil, queue_name: :nil
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  def start() do
    start_link([])
  end

  def init([]) do
    GenServer.cast(__MODULE__, {:poll})
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
    {output, return_code} = System.cmd("sh", [check_path])
    # push results to queue
    # GenSerever.cast(WamekuClientScratch.Producer, {:pub, {output, return_code}})
    {:noreply, state}
  end

  def handle_cast({:poll}, state) do
    spawn_link(__MODULE__, :loop, [state])
    {:noreply, state}
  end

  def loop(state) do
    #|> Enum.each(fn(check) -> GenServer.cast(WamekuClientScratch.CheckRunner, {:check, Map.get(check, "check")}) end)
    {:ok, files} = File.ls("/tmp/checks/config") 
    files
    |> Enum.into([], fn(x) -> Poison.decode!(File.read!("/tmp/checks/config/" <> x)) end)
    |> Enum.each(fn(check) -> time_to_check?(Map.get(check, "check")) end)
    :timer.sleep(1000)
    loop(state)
  end

  defp time_to_check?(check) do
    check_name = Map.get(check, "name")
    check_interval = Map.get(check, "interval")

    case WamekuClientScratch.Cache.lookup(:cache, check_name) do
      {:ok, {name, check_metadata}} ->
        now = :os.system_time(:seconds)
        last_checked_time = check_metadata.last_checked
        difference = now - last_checked_time
        Logger.debug("now #{now} -- last_checked: #{last_checked_time} -- difference: #{difference} -- interval: #{check_interval}")
        if difference == check_interval do
          Logger.debug("time to run #{name}")
          GenServer.cast(WamekuClientScratch.CheckRunner, {:check, check})
        end
      :error ->
        Logger.info "no check found in cache, must be first check"
        GenServer.cast(WamekuClientScratch.CheckRunner, {:check, check})
    end
  end


end
