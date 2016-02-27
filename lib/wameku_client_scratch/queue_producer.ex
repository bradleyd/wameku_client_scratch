defmodule WamekuClientScratch.QueueProducer do
use GenServer
  use AMQP
  require Logger

  @amqp Application.get_env(:wameku_client_scratch, :amqp)

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
    {:ok, conn} = Connection.open(heartbeat: 60, host: @amqp.host, port: 5672, username: @amqp.username, password: @amqp.password, virtual_host: @amqp.virtual_host)
    {:ok, chan} = AMQP.Channel.open(conn)
    queue       = @amqp.queue_name
    queue_error = "#{queue}_error"
    exchange    = @amqp.exchange_name
    Queue.declare(chan, queue_error, durable: true)
    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error que    ue
    Queue.declare(chan, queue, durable: true,
    arguments: [{"x-dead-letter-exchange", :longstr, ""},
      {"x-dead-letter-routing-key", :longstr, queue_error}])
    Exchange.direct(chan, exchange, durable: true)
    Queue.bind(chan, queue, exchange)
    {:ok, %State{channel: chan, connection: conn}}
  end

  def handle_cast({:publish, message}, state) do
    # serialize message
    serialized_message = Poison.encode!(message)
    case AMQP.Basic.publish(state.channel, @amqp.exchange_name, "", serialized_message) do
      :ok ->
        Logger.info("Published message #{inspect(message)} to queue")
      error ->
        Logger.error("Caught error while publishing message to queue")
    end
    {:noreply, state}
  end
end
