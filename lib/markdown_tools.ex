defmodule MarkdownTools do
  require Logger

  def start(:normal, []) do
    case Burrito.Util.Args.get_arguments() do
      [_mix, "run", "--", command, file] ->
        result =
          case File.read(file) do
            {:ok, input} ->
              case command do
                "url-fix" -> {:ok, MarkdownTools.convert(input)}
                "compact" -> {:ok, MarkdownTools.compact(input)}
                other -> {:error, "Unknown command: #{other}"}
              end

            _ ->
              {:error, "Failed to open file #{file}"}
          end

        case result do
          {:ok, output} -> File.write!(file, output)
          {:error, message} -> IO.puts("Error: #{message}")
        end

      [arg1, arg2 | _] ->
        IO.puts("Usage: #{arg1} #{arg2} -- <command> <input file>")
        IO.puts("Where <command> is one of: url-fix, compact")
    end

    # System.halt(0)
    # opts = [strategy: :one_for_one, name: MarkdownTools]
    # children = []
    # Supervisor.start_link(children, opts)
    {:ok, self()}
  end

  def compact(input) do
    input
    |> String.split("\n")
    |> Enum.reject(fn line -> line == "" end)
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  def convert(input) do
    input
    |> String.split()
    |> Enum.map(fn line ->
      IO.write("#{line} -> ")

      {:ok, document} =
        Tesla.get!(line).body
        |> Floki.parse_document()

      [{"title", _, [title]}] = Floki.find(document, "title")

      IO.write(title <> "\n")

      "- [#{title}](#{line})\n"
    end)
    |> Enum.join()
  end
end
