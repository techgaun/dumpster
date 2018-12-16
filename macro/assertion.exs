defmodule Assertion do
  defmacro assert({op, _, [lhs, rhs]}) do
    quote bind_quoted: [op: op, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(op, lhs, rhs)
    end
  end
end

defmodule Assertion.Test do
  def assert(:==, value, value), do: passed()

  def assert(:==, lhs, rhs) do
    failed("be equal to", lhs, rhs)
  end

  def assert(:>, lhs, rhs) when lhs > rhs, do: passed()
  def assert(:>, lhs, rhs) do
    failed("be greater than", lhs, rhs)
  end

  defp passed, do: IO.write IO.ANSI.green() <> "."

  defp failed(msg, lhs, rhs) do
    IO.puts IO.ANSI.red() <> 
      """
      FAILURE:
        Expected:           #{lhs}
        to #{msg}:          #{rhs}
      """
  end
end
