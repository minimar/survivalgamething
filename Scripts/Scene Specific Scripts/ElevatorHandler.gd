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
	

func updateAreaWarp():
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
	var player = get_tree().get_first_node_in_group("Player")
	player.scenePause = true
	var playerChoice = floors[await dialogueHandler.playerDialogueChoice(floors)]
	var totalFloorDifference = int(playerChoice) - int(floor)
	var tween = get_tree().create_tween()
	const secondsPerFloor = 2
	const cameraMovementVector = Vector2(0,-5)
	if totalFloorDifference > 0:
		if $TileMap/AnimatedSprite2D.animation == 'doorOpen':
			tween.tween_callback($TileMap/AnimatedSprite2D.play.bind('doorClose'))
		tween.tween_property($Camera2D,"position",$Camera2D.position+cameraMovementVector,1)
		tween.tween_interval(totalFloorDifference*secondsPerFloor)
		tween.tween_property($Camera2D,"position",$Camera2D.position-cameraMovementVector,1)
		tween.tween_callback($TileMap/AnimatedSprite2D.play.bind('doorOpen'))
	else:
		if $TileMap/AnimatedSprite2D.animation == 'doorOpen':
			tween.tween_callback($TileMap/AnimatedSprite2D.play.bind('doorClose'))
		tween.tween_property($Camera2D,"position",$Camera2D.position-cameraMovementVector,1)
		tween.tween_interval(abs(totalFloorDifference)*secondsPerFloor)
		tween.tween_property($Camera2D,"position",$Camera2D.position+cameraMovementVector,1)
		tween.tween_callback($TileMap/AnimatedSprite2D.play.bind('doorOpen'))
	floor = playerChoice
	player.scenePause = false
	updateAreaWarp()

func _on_animation_changed():
	if $TileMap/AnimatedSprite2D.animation == 'doorOpen':
		await $TileMap/AnimatedSprite2D.animation_finished
		$TileMap/AreaWarp.collision_mask = 8
		$TileMap/AreaWarp.collision_layer = 8
	else:
		$TileMap/AreaWarp.collision_mask = 0
		$TileMap/AreaWarp.collision_layer = 0
