defmodule AnimalTest do
  use ExUnit.Case
  doctest Animal

  test "Dog is friendly" do
		dog = %Dog{}
		assert Animal.friendly?(dog) == true
  end

	test "Cat is friendly" do
		cat = %Cat{}
		assert Animal.friendly?(cat) == true
  end

	test "Shark is not friendly" do
		shark = %Shark{}
		assert Animal.friendly?(shark) == true
  end

end
