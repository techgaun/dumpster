defmodule TimeSeries do

	defstruct times: 5, num_points: 100_000
	
	def start(args \\ System.argv()) do
		time_start = :os.system_time(:milli_seconds)
		case args do
			["true"] ->
				async(5, 100_000, true)
			[x] ->
				async(String.to_integer(x))
			[x, y] ->
				async(String.to_integer(x), String.to_integer(y))
			[x, y, z] ->
				async(String.to_integer(x), String.to_integer(y), z == "true")
			_ ->
				async()
		end
		time_end = :os.system_time(:milli_seconds)
		IO.puts "total time for all tasks: #{time_end - time_start}"
	end
	
	defp async(times \\ 5, num_points \\ 100_000, debug \\ false)

	defp async(times, num_points, debug) when times > 0 do
		task = Task.async(fn -> calc(num_points, debug) end)
		async(times - 1, num_points, debug)
		Task.await(task, 20000)
	end

	defp async(times, num_points, debug) when times == 0 do
		if debug do IO.puts "done with #{num_points}" end
	end

	def calc(num_points, debug \\ true) do
    time_start = :os.system_time(:milli_seconds)
    :random.seed(:os.timestamp)
    collection = Enum.map(1..num_points, fn (_) -> :random.uniform() * 100 end)
    sample_size = 15 * 60

    {first, rest} = Enum.split(collection, sample_size)
    sum = Enum.sum(first)
    avg = sum / sample_size

    averages = foldish(first, [], rest, sum, sample_size, [avg])

    # averages = do_foldish(collection, samples)

    time_end = :os.system_time(:milli_seconds)

		if debug do
			IO.puts "#{inspect self} Averages (#{length averages}): #{inspect averages}"
			IO.puts "#{inspect self} total time: #{time_end - time_start}"
		end
  end

  defp foldish(_, _, [], _, _, averages) do
    Enum.reverse(averages)
  end

  defp foldish([], current_sample, rest, prev_sum, sample_size, averages) do
    foldish(Enum.reverse(current_sample), [], rest, prev_sum, sample_size, averages)
  end

  defp foldish([h_first | first], current_sample, [h_rest | rest], prev_sum, sample_size, averages) do
    new_sum = prev_sum - h_first + h_rest
    avg = new_sum / sample_size

    foldish(first, [h_rest] ++ current_sample, rest, new_sum, sample_size, [avg] ++ averages)
  end
end

TimeSeries.start
