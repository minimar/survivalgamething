extends Node2D
class_name SubsceneHandler

@export var activeSubsceneDict: String
var player
var subscene: String
const cityInterior = {
	"apartmentBuilding1": {
		"player": Vector2(64,93),
		"camera": Vector2(0,0)
	},
	"apartmentBuilding1A": {
		"player": Vector2(),
		"camera": Vector2(488,-56)
	}
}


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	


func changeSubScene(newSubscene,changePlayerPosition = false):
	var playerTargetPosition
	var cameraTargetPosition
	if get(activeSubsceneDict).has(newSubscene):
		cameraTargetPosition = get(activeSubsceneDict)[newSubscene]["camera"]
		playerTargetPosition = get(activeSubsceneDict)[newSubscene]["player"]
	
	if not cameraTargetPosition and not cameraTargetPosition == Vector2() :
		push_error('No subscene found: '+newSubscene+' in: '+activeSubsceneDict)
		return
	subscene = newSubscene
	if changePlayerPosition:
		player.position = playerTargetPosition
	get_parent().localCamera.position = cameraTargetPosition
