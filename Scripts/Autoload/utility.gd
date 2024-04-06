extends Node

#Returns a random member of the provided Array
func getRandomArrayMember(array: Array):
	return array[randi_range(0,array.size()-1)]
