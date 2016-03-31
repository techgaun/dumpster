defmodule Crap do

  def calc(num_points) do

    time_start = :os.system_time(:milli_seconds);
    collection = 1..num_points;

    collection
    |> Enum.map(&Task.async(fn -> &1 = get_random end))
    |> Enum.map(&Task.await/1)
    |> Enum.chunk(15 * 60, 1)
    |> Enum.map(&Task.async(fn -> average(&1) end))
    |> Enum.map(&Task.await/1)
    |> IO.inspect
    
    time_end = :os.system_time(:milli_seconds);
    IO.puts("Total time: ");
    IO.puts(time_end - time_start);

  end

  def sum([head|tail], total) do
      sum(tail, head + total)
  end

  def sum([], total) do
      total
  end

  def average(list) do
      len = length list;
      sum(list, 0) / len;
  end

  def get_random do
    :random.seed(:os.timestamp)
    :random.uniform * 100
  end
end

Crap.calc(100_000)
