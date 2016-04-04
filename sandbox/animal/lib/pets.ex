defmodule Pet do
	@callback pet(String.t) :: :atom
	@callback feed(String.t, String.t) :: :any

	def checkup(pet, food \\ :fish) do
		IO.puts "is #{pet.name} friendly? #{Animal.friendly?(pet)}"
		IO.puts "does #{pet.name} eat #{food}? #{Animal.feed(pet, food)}"
	end
end

defmodule Cat do
	@behaviour Pet
	defstruct age: 5, name: "kitty"

end

defmodule Wolf do
	@behaviour Pet
	@derive Animal
	defstruct age: 5, name: "Scar"

	@spec pet(String.t) :: :atom
	def pet(animal) do
		:bite
	end
end

defmodule Shark do
	@behaviour Pet
	@derive Animal
	defstruct age: 15, name: "Jaws"
end

defmodule Dog do
	@behaviour Pet
	@derive Animal
	defstruct age: 2, name: "Max"

	@spec pet :: :atom
	def pet do
		:woof
	end

end
