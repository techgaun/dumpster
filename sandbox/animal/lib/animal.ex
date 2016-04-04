defprotocol Animal do
  @doc "animals do things"
	def friendly?(_)
	def pet(animal)
	def feed(animal, food)
end

defimpl Animal, for: Any do
	def friendly?(_), do: false

	@spec pet(String.t) :: :atom
	def pet(animal) do
		:fight
	end

	@spec feed(String.t, String.t) :: atom
	def feed(_, food) do
		# assume they are all carnivores :)
		case food do
			:meat ->
				:yum
			_ ->
				:yuck
		end
	end
end
