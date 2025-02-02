defmodule MarkdownTools do
  require Logger

  def start(:normal, []) do
    case Burrito.Util.Args.get_arguments() do
      [_mix, "run", "--", command, file] ->
        result =
          case File.read(file) do
            {:ok, input} ->
              case command do
                "url-fix" ->
                  IO.puts("Fixing URLs in #{file}")
                  MarkdownTools.convert(input)

                "compact" ->
                  IO.puts("Removing newlines in #{file}")
                  MarkdownTools.compact(input)

                other ->
                  {:error, "Unknown command: #{other}"}
              end

            _ ->
              {:error, "Failed to open file #{file}"}
          end

        case result do
          {:ok, output} -> File.write!(file, output)
          {:error, message} -> IO.puts("Error: #{message}")
        end

      [] ->
        usage("markdown-tools")
        System.stop(0)

      ["url-fix", file] ->
        IO.puts("Fixing URLs in #{file}")

        case MarkdownTools.convert(File.read!(file)) do
          {:ok, output} -> File.write!(file, output)
          {:error, message} -> IO.puts("Error: #{message}")
        end

        System.stop(0)

      ["url-fix"] ->
        IO.puts("Fixing URLs in stdin")

        case MarkdownTools.convert(File.read!("/dev/stdin")) do
          {:ok, output} -> File.write!("/dev/stdout", output)
          {:error, message} -> IO.puts("Error: #{message}")
        end

        System.stop(0)

      ["compact", file] ->
        IO.puts("Removing newlines in #{file}")

        case MarkdownTools.compact(File.read!(file)) do
          {:ok, output} -> File.write!(file, output)
          {:error, message} -> IO.puts("Error: #{message}")
        end

        System.stop(0)

      ["compact"] ->
        IO.puts("Removing newlines in stdin")

        case MarkdownTools.compact(File.read!("/dev/stdin")) do
          {:ok, output} -> File.write!("/dev/stdout", output)
          {:error, message} -> IO.puts("Error: #{message}")
        end

        System.stop(0)

      [_] ->
        usage("markdown-tools")
        System.stop(0)

      [arg1, arg2 | _] ->
        usage("#{arg1} #{arg2}")
    end

    # System.halt(0)
    # opts = [strategy: :one_for_one, name: MarkdownTools]
    # children = []
    # Supervisor.start_link(children, opts)
    {:ok, self()}
  end

  defp usage(cmd) do
    IO.puts("Usage: #{cmd} <command> <input file>")
    IO.puts("Where <command> is one of: url-fix, compact")
  end

  def compact(input) do
    {:ok,
     input
     |> String.split("\n")
     |> Enum.reject(fn line ->
       if line == "" do
         Logger.debug("Skipping blank line")
         true
       else
         Logger.debug("Keep: #{line}...")
         false
       end
     end)
     |> Enum.join("\n")
     |> Kernel.<>("\n")}
  end

  def convert(input) do
    {:ok,
     input
     |> String.split("\n")
     |> Enum.map(fn line ->
       url_regexp = ~r(^https?://\S*$)

       if Regex.match?(url_regexp, line) do
         IO.write("#{line} -> ")

         {:ok, document} =
           Tesla.get!(line).body
           |> Floki.parse_document()

         title =
           case Floki.find(document, "title") do
             [{"title", _, [title]} | _] -> String.trim(title)
             [] -> "Unknown title"
           end

         try do
           IO.write(title <> "\n")
         rescue
           e in ArgumentError ->
             IO.write("ERROR #{inspect(e)} #{inspect(title)}\n")
         end

         "- [#{title}](#{line})"
       else
         line
       end
     end)
     |> Enum.join("\n")}
  end
end
