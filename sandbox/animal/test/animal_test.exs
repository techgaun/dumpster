defmodule AnimalTest do
  use ExUnit.Case
  doctest Animal

	setup_all do
		dog = %Dog{}
		shark = %Shark{}
		cat = %Cat{}
		wolf = %Wolf{}
		{:ok, dog: dog, shark: shark, cat: cat, wolf: wolf}
	end
	
  test "Dog is friendly", context do
		assert Animal.friendly?(context[:dog]) == true
  end

	test "Cat is friendly", context do
		assert Animal.friendly?(context[:cat]) == true
  end

	test "Sharks are not friendly", context do
		assert Animal.friendly?(context[:shark]) != true
  end

	test "Wolves are not friendly", context do
		assert Animal.friendly?(context[:wolf]) != true
  end

end
