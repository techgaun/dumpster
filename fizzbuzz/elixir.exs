fun =
  fn
    0, 0, _ -> "FizzBuzz"
    0, _, _ -> "Fizz"
    _, 0, _ -> "Buzz"
    _, _, c -> c
  end

fb = fn n -> fun.(rem(n, 3), rem(n, 5), n) end

for i <- 1..100, do: IO.puts fb.(i)
