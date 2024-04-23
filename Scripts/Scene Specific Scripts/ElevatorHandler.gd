extends Node2D

var elevatorID = SceneSwitcher.elevatorID
var floor = SceneSwitcher.elevatorFloor
var dialogueHandler

const elevatorData := {
	"cityApartment1": {
		#Number corresponds to the floor number, 1 is the ground floor you gremlin
		#The vector corresponds to the position of the elevator for that floor (Where to put the player specifically)
		"1": Vector2(),
		"2": Vector2(),
		"3": Vector2(),
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_parent().ready
	dialogueHandler = get_parent().find_child("UI/Dialogue Handler")
