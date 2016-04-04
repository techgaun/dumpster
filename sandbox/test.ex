pet = %Cat{:name => "Alexander"}
pet2 = %Dog{:name => "Fido"}
pet3 = %Wolf{}
pet4 = %Shark{}
pets = [pet, pet2, pet3, pet4]

for pet <- pets, Animal.friendly?(pet), do: Pet.checkup(pet)

