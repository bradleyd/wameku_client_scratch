defmodule WamekuClientScratch.QueueProducer do
use GenServer  
  use AMQP
  require Logger

  @exchange    "clients_exchange"
  @queue       "clients"
  @queue_error "#{@queue}_error"

  defmodule State do
    defstruct channel: :nil, connection: :nil
  end

  defmodule CheckMetadata do
    defstruct last_checked: :nil, exit_code: :nil, history: [], host: :nil
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init([]) do
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
    {:ok, %State{channel: chan, connection: conn}}
  end

  def handle_cast({:publish, message}, state) do
    # serialize message
    serialized_message = Poison.encode!(message)
    case AMQP.Basic.publish(state.channel, @exchange, "", serialized_message) do
      :ok ->
        Logger.info("Published message #{inspect(message)} to queue")
      error ->
        Logger.error("Caught error while publishing message to queue")
    end
    {:noreply, state}
  end
end
