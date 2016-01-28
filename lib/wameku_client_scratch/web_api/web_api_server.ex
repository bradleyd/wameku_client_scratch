defmodule WamekuClientScratch.WebApiServer do
  require Logger

  def start_link() do
    opts  = [port: 4000, ip: {127,0,0,1}, compress: true, linger: {true, 10}]

    #if port = System.get_env("WEB_API_PORT") do
    #  opts = Keyword.put(opts, :port, String.to_integer(port))
    #end

    #if ip = System.get_env("WEB_API_BIND_INTERFACE") do
    #  {:ok, ip_tuple} = :inet.parse_address(to_char_list(ip))
    #  opts = Keyword.put(opts, :ip, ip_tuple)
    #end

    Logger.debug(inspect(opts))
    Logger.info "Starting Wameku Api on port #{inspect(opts[:ip])}:#{opts[:port]}"
    {:ok, _} = Plug.Adapters.Cowboy.http(WamekuClientScratch.WebApiRouter, [], opts)
  end

end
