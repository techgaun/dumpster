time_start = :os.system_time(:milli_seconds);

defmodule Rand do
	def get_random do
		:random.seed(:os.timestamp)
		:random.uniform * 100
	end
end

defmodule Summation do
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
end

num_points = 100000;
fifteen_minutes = 15 * 60;

all_points = Enum.map(1..num_points, fn x -> Rand.get_random end)

chunks = Enum.chunk(all_points, fifteen_minutes, 1);


calculated_points = Enum.map(chunks, fn x -> Summation.average(x) end);
time_end = :os.system_time(:milli_seconds);

IO.puts("Total elements:");
IO.puts(length all_points);

IO.puts("Total time: ");
IO.puts(time_end - time_start);