extends Item
class_name Food

var usable = true
var foodSaturation: int
var type: String: 
	set(value):
		if not value in ["raw","basic","cooked"]:
			printerr("Value: "+str(value)+" not valid type in Food.gd")
		else:
			type = value
