defprotocol Animal do
  @doc "animals do things"
	def friendly?(_)
end

defimpl Animal, for: Any do
	def friendly?(_), do: false
end

defimpl Animal, for: Cat do
	def friendly?(_), do: true
end
