defmodule Cat do
	defstruct age: 5, name: "kitty"

	def pet do
		:purr
	end
	
end

defmodule Wolf do
	@derive Animal
	defstruct age: 5, name: "Scar"

	def pet do
		:bite
	end
end

defmodule Shark do
	@derive Animal
	defstruct age: 15, name: "Jaws"
end

defmodule Dog do
	@derive Animal
	defstruct age: 2, name: "Max"

	def pet do
		:woof
	end
end
