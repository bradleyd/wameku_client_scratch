defmodule WamekuClientScratch.QueueProducer do
use GenServer  
  use AMQP
  require Logger

  @exchange    "test_exchange"
  @queue       "test_queue"
  @queue_error "#{@queue}_error"

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
    Queue.declare(chan, @queue_error, durable: true)
    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error que    ue
    Queue.declare(chan, @queue, durable: true,
    arguments: [{"x-dead-letter-exchange", :longstr, ""},
      {"x-dead-letter-routing-key", :longstr, @queue_error}])

    #AMQP.Queue.declare(chan, "test_queue", durable: true)
    Exchange.direct(chan, @exchange, durable: true)
    Queue.bind(chan, @queue, @exchange)

    #AMQP.Exchange.declare(chan, "test_exchange", durable: true)
    #AMQP.Queue.bind chan, "test_queue", "test_exchange"
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
