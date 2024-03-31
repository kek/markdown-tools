defmodule Titles do
  require Logger

  def start(:normal, []) do
    [_, _, "--", file] = Burrito.Util.Args.get_arguments() |> IO.inspect()

    case File.read(file) do
      {:ok, input} -> Titles.convert(input)
      _ -> IO.puts("No file given")
    end

    # System.halt(0)
    # opts = [strategy: :one_for_one, name: Titles]
    # children = []
    # Supervisor.start_link(children, opts)
    {:ok, self()}
  end

  def convert(input) do
    input
    |> String.split()
    |> Enum.map(fn url ->
      IO.write("url -> ")

      {:ok, document} =
        Tesla.get!(url).body
        |> Floki.parse_document()

      [{"title", _, [title]}] = Floki.find(document, "title")

      IO.write(title <> "\n")

      "- [#{title}](#{url})\n"
    end)
    |> Enum.join()
  end
end
