extends Node2D

var elevatorID = SceneSwitcher.elevatorID
var floor = str(SceneSwitcher.elevatorFloor)
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
@onready var areaWarp = $TileMap/AreaWarp
var currentElevator = elevatorData[elevatorID]
# Called when the node enters the scene tree for the first time.
func _ready():
	#print("ElevatorID: " + elevatorID)
	await get_parent().ready
	dialogueHandler = get_parent().get_node("UI/Dialogue Handler")
	areaWarp.targetScene = currentElevator["scene"]
	areaWarp.subscene = currentElevator["subscene"]
	areaWarp.warpCoordinates = currentElevator[floor]



func _on_elevator_button_pressed():
	var floors = []
	for key in elevatorData[elevatorID]:
		if key not in ["scene","subscene"]:
			floors.append(key)
	floors.erase(floor)
	print("prompting Player Choice")
	var playerChoice = await dialogueHandler.playerDialogueChoice(floors)
	print(playerChoice)
