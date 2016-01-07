defmodule WamekuClientScratch.QueueProducer do
  use GenServer  
  use AMQP
  require Logger

  defmodule State do
    defstruct channel: :nil
  end

  defmodule CheckMetadata do
    defstruct last_checked: :nil, exit_code: :nil, history: [], host: :nil
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init([]) do
    # call cast on self to loop and fetch messages
    #aws_key = System.get_env("AWS_ACCESS_KEY_ID")
    #secret_key = System.get_env("AWS_SECRET_ACCESS_KEY")
    #aws_url = System.get_env("AWS_URL") || "sqs.us-west-2.amazonaws.com"
    #queue_name = System.get_env("SENSOR_QUEUE_NAME") || "sensorqs-dev-queue"
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)
    AMQP.Queue.declare chan, "test_queue"
    AMQP.Exchange.declare chan, "test_exchange"
    AMQP.Queue.bind chan, "test_queue", "test_exchange"
    {:ok, %State{channel: chan}}
  end
 
  def handle_cast({:publish, message}, state) do
    Logger.info("here in publish")
    # serialize message
    serialized_message = Poison.encode!(message)
    case AMQP.Basic.publish(state.channel, "test_exchange", "", serialized_message) do
      :ok ->
        Logger.info("Published message #{inspect(message)} to queue")
      error ->
        Logger.error("Caught error while publishing message to queue")
    end
    {:noreply, state}
  end
end
