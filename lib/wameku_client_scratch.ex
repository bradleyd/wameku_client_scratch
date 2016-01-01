defmodule WamekuClientScratch do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      supervisor(WamekuClientScratch.GenericChecksSupervisor, []),
      worker(WamekuClientScratch.Cache, [:cache]),
      #worker(WamekuClientScratch.Scheduler, []),
      worker(WamekuClientScratch.CheckRunner, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WamekuClientScratch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
