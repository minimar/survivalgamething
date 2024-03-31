extends Item
class_name Clothing

var usable = true

var armorRating: int
var movementReduction: int
var type: String: 
	set(value):
		if not value in ["head","torso","legs"]:
			printerr("Value: "+str(value)+" not valid type in clothing.gd")
		else:
			type = value
