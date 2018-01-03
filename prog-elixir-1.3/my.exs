defmodule My do
  def sum(n), do: do_sum(n, 0)
  defp do_sum(0, sum), do: sum
  defp do_sum(n, sum), do: do_sum(n - 1, sum + n)

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))

  def guess(actual, l..h) when actual >= l and actual <= h do
    do_guess(actual, div(l + h, 2), l, h)
  end

  defp do_guess(actual, actual, _, _), do: actual
  defp do_guess(actual, guess, l, _h) when actual < guess, do: do_guess(actual, div(guess + l, 2), l, guess)
  defp do_guess(actual, guess, _l, h) when actual > guess, do: do_guess(actual, div(guess + h, 2), guess, h)

  def square([]), do: []
  def square([h | t]), do: [h * h | square(t)]

  def map([], _), do: []
  def map([h | t], fun), do: [fun.(h) | map(t, fun)]

  def suml([]), do: 0
  def suml([h | t]), do: h + suml(t)

  def mapsum(list, fun), do: do_mapsum(list, fun, 0)
  defp do_mapsum([], _, sum), do: sum
  defp do_mapsum([h | t], fun, sum), do: do_mapsum(t, fun, sum + fun.(h))

  def max([]), do: nil
  def max([h | t]), do: do_max(t, h)
  defp do_max([], max), do: max
  defp do_max([h | t], max) when max >= h, do: do_max(t, max)
  defp do_max([h | t], max) when max < h, do: do_max(t, h)

  def caesar([], _), do: []
  def caesar([h | t], n) when (h + n) <= ?z, do: [h + n, caesar(t, n)]
  def caesar([h | t], n), do: [h + n - 26, caesar(t, n)]

  def swap([]), do: []
  def swap([a, b | t]), do: [b, a | swap(t)]
  def swap([_]), do: raise "Can not swap a list with odd nuber of elements"

  def all?(l, fun), do: do_all?(l, fun, true)
  def do_all?(_, _, false), do: false
  def do_all?([], _fun, _), do: true
  def do_all?([h | t], fun, true), do: do_all?(t, fun, fun.(h))

  def flatten(list), do: do_flatten(list, [])

  defp do_flatten([], tail), do: tail
  defp do_flatten([h | t], tail) when is_list(h) do
    do_flatten(h, do_flatten(t, tail))
  end
  defp do_flatten([h | t], tail), do: [h | do_flatten(t, tail)]
end
