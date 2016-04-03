defprotocol Animal do
  @doc "animals do various things"
  def eat(food)
  def sleep(time)
	def speak(words)
end

defimpl Animal, for: Any do
  def eat(_), do: :nothing
  def sleep(_), do: 8
	def speak(words), do: :nothing
end

defmodule Dog do
	def eat(food) do
	end

	def sleep(time) do
	end
end

defmodule Cat do
end
