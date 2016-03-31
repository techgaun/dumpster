defmodule Crap2 do
  def calc(num_points) do
    time_start = :os.system_time(:milli_seconds)
    :random.seed(:os.timestamp)

    collection = Enum.map(1..num_points, fn (_) -> :random.uniform() * 100 end)
    IO.puts "got collection"
    chunk_size = 15 * 60
    chunks = Enum.chunk(collection, chunk_size, 1)
    IO.puts "got chunks"
    IO.puts "num chunks: #{length(chunks)}"

    chunks
    |> Stream.map(fn (chunk) ->
      Task.async(fn () ->
        sum = Enum.sum(chunk)
        len = length(chunk)
        sum / len
      end)
    end)
    |> Enum.map(&Task.await/1)
    |> IO.inspect

    time_end = :os.system_time(:milli_seconds)
    IO.puts "total time: #{time_end - time_start}"
  end
end
Crap2.calc(100_000)
