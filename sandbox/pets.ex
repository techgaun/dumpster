defmodule Cat do
	defstruct age: 5, name: "kitty"
end

defmodule Wolf do
	@derive Animal
	defstruct age: 5, name: "Scar"

	def pet do
		:bite
	end
end

defmodule Dog do
	@derive Animal
	defstruct age: 2, name: "Max"

	def pet do
		:woof
	end
end
