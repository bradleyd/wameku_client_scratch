# WamekuClientScratch

This is an attempt to write a system monitoring solution in Elixir.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add wameku_client_scratch to your list of dependencies in `mix.exs`:

        def deps do
          [{:wameku_client_scratch, "~> 0.0.1"}]
        end

  2. Ensure wameku_client_scratch is started before your application:

        def application do
          [applications: [:wameku_client_scratch]]
        end
