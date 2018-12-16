defmodule Assertion do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      Module.register_attribute __MODULE__, :tests, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run do
        IO.puts "Running tests: #{inspect @tests}"
        Assertion.Test.run(@tests, __MODULE__)
      end
    end
  end

  defmacro refute({op, _, [lhs, rhs]}) do
    quote bind_quoted: [op: op, lhs: lhs, rhs: rhs] do
      Assertion.Test.refute(op, lhs, rhs)
    end
  end

  defmacro assert({op, _, [lhs, rhs]}) do
    quote bind_quoted: [op: op, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(op, lhs, rhs)
    end
  end

  defmacro assert(value) do
    quote bind_quoted: [value: value] do
      Assertion.Test.assert(value)
    end
  end

  defmacro test(desc, do: block) do
    test_fun = String.to_atom(desc)

    quote do
      @tests {unquote(test_fun), unquote(desc)}

      def unquote(test_fun)(), do: unquote(block)
    end
  end
end

defmodule Assertion.Test do
  def run(tests, module) do
    {total_ms, _} =
      :timer.tc(fn ->
        tests
        |> Enum.map(fn {test_func, test_desc} ->
          Task.async(fn ->
            case apply(module, test_func, []) do
              :ok -> passed()
              {:fail, reason} ->
                IO.puts IO.ANSI.red() <> """
                FAILURE: #{test_desc}
                #{reason}
                """
            end
          end)
        end)
        |> Enum.map(&Task.await/1)
        :ok
      end)

    IO.puts "Total time taken: #{total_ms / 1_000_000} seconds"
  end

  def refute(op, lhs, rhs) do
    case assert(op, lhs, rhs) do
      :ok -> {:fail, "refuted to be"}
      _ -> :ok
    end
  end

  def assert(true), do: :ok
  def assert(false), do: {:fail, "to be falsy"}

  def assert(:==, value, value), do: :ok

  def assert(:==, lhs, rhs) do
    failed("be equal to", lhs, rhs)
  end

  def assert(:>, lhs, rhs) when lhs > rhs, do: :ok
  def assert(:>, lhs, rhs) do
    failed("be greater than", lhs, rhs)
  end

  defp passed, do: IO.write IO.ANSI.green() <> "."

  defp failed(msg, lhs, rhs) do
    {
      :fail,
      """
      FAILURE:
        Expected:           #{lhs}
        to #{msg}:          #{rhs}
      """
    }
  end
end

defmodule MathTest do
  use Assertion

  test "integers sub/add" do
    assert 1 + 1 == 2
    assert 2 + 3 == 5
    assert 5 - 5 == 0
    assert 5 == 5
    refute 5 == 6
    :timer.sleep(2_000)
  end

  test "boolean" do
    assert true
  end

  test "refute fails" do
    refute 5 == 5
  end
end
