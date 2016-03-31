time_start = :os.system_time(:milli_seconds)

defmodule Rand do
    def seed_random do
        :random.seed(:os.timestamp())
    end
    def get_random do
        :random.uniform * 100
    end
end

defmodule Summation do
    def sum(list, acc \\ 0)

    def sum([], total) do
        total
    end
    def sum([head|tail], total) do
        sum(tail, head + total)
    end

    def average(list) do
        len = length list;
        sum(list, 0) / len;
    end
    
    def sma(points, window) do
      [first | _] = points
      {first_window, rest} = Enum.split(points, window)
      first_total = sum(first_window)
      first_avg =  first_total / window
      
      Enum.reverse( do_sma(rest, [first_avg], first_total, first, window) )
    end
    
    defp do_sma([next|rest], acc, last_total, last_next, window) do
      last_total = last_total + next - last_next 
      sma = last_total / window
      do_sma(rest, [ sma | acc], last_total, next, window )
    end
    
    defp do_sma([], acc, _last_total, _last_next, _window) do
      acc
    end
    
end

num_points = 100000;
fifteen_minutes = 900;

Rand.seed_random
all_points = Enum.map(1..num_points, fn _ -> Rand.get_random end)

calculated_points = Summation.sma(all_points, fifteen_minutes) 

IO.inspect(calculated_points)

time_end = :os.system_time(:milli_seconds);
IO.puts("Total elements:");
IO.puts(length all_points);

IO.puts("Total time: ");
IO.puts(time_end - time_start);