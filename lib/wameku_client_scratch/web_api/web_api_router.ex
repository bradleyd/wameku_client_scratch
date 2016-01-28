defmodule WamekuClientScratch.WebApiRouter do
  use Plug.Router
  import Plug.Conn
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch
  
  def init(options) do
    options
  end

  #forward "/images", to: DockerApiProxy.Images.Router
  #forward "/containers", to: DockerApiProxy.Containers.Router
  #forward "/hosts", to: DockerApiProxy.Hosts.Router

  get "/hello" do
    send_resp(conn, 200, "\nworld")
  end

  get "/checks" do
    {:ok, keys} = WamekuClientScratch.Cache.keys(:cache)                      
    checks = Enum.map(keys, fn(x) -> WamekuClientScratch.Cache.lookup(:cache, x) end)
    payload =
    Enum.map(checks, fn(check) -> 
      {:ok, {name, metadata}} = check 
      metadata
    end)
    Logger.debug(inspect(payload))
    encoded = Poison.encode!(payload)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, encoded)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

end
