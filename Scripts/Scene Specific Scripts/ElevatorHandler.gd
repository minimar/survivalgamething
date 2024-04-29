extends Node2D

var elevatorID = SceneSwitcher.elevatorID
var floor = SceneSwitcher.elevatorFloor
var dialogueHandler: DialogueHandler

const elevatorData := {
	"cityApartment1": {
		#Scene as File
		"scene": "res://Scenes/city_building_interiors.tscn",
		"subscene": "apartmentBuilding1",
		#Number corresponds to the floor number, 1 is the ground floor you gremlin
		#The vector corresponds to the position of the elevator for that floor (Where to put the player specifically)
		"1": Vector2(-97,53),
		"2": Vector2(-97,-12),
		"3": Vector2(-97,-77),
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_parent().ready
	dialogueHandler = get_parent().find_child("UI/Dialogue Handler")



func _on_elevator_button_pressed():
	var floors = []
	for key in elevatorData[elevatorID]:
		if key not in ["scene","subscene"]:
			floors.append(key)
	floors.erase(floor)
	print("prompting Player Choice")
	var playerChoice = await dialogueHandler.playerDialogueChoice(floors)
	
