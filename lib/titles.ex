defmodule Titles do
  def start(:normal, []) do
    args = Burrito.Util.Args.get_arguments()
    IO.puts("Args: #{inspect(args)}")
    # System.halt(0)
    # opts = [strategy: :one_for_one, name: Titles]
    # children = []
    # Supervisor.start_link(children, opts)
    {:ok, self()}
  end
end
