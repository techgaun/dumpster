pet = %Cat{:name => "Alexander"}
pet2 = %Dog{:name => "Fido"}
pet3 = %Wolf{}
pet4 = %Shark{}
pets = [pet, pet2, pet3, pet4]

for pet <- pets, do: IO.puts "is #{pet.name} friendly? #{Animal.friendly?(pet)}"
