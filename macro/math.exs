defmodule Math do
  defmacro say({:+, _, [lhs, rhs]}) do
    quote do
      lhs = unquote(lhs)
      rhs = unquote(rhs)

      result = lhs + rhs

      IO.puts "Result: #{result}"

      result
    end
  end

  defmacro say({:*, _, [lhs, rhs]}) do
    quote do
      lhs = unquote(lhs)
      rhs = unquote(rhs)

      result = lhs + rhs

      IO.puts "Result: #{result}"

      result
    end
  end
end
