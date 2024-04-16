extends Node2D
class_name SubsceneHandler

var player
var subscene: String
var cityInteriorSubscenes = {
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
	print('test')
	var playerTargetPosition
	var cameraTargetPosition
	if cityInteriorSubscenes.has(newSubscene):
		if cameraTargetPosition:
			push_error("TWO DICTS, SAME SUBSCENE ID: cityInteriorSubScenes")
		print('test2')
		cameraTargetPosition = cityInteriorSubscenes[newSubscene]["camera"]
		playerTargetPosition = cityInteriorSubscenes[newSubscene]["player"]
		
	#ADD NEW SUBSCENE DICTS HERE
	if not cameraTargetPosition and not cameraTargetPosition == Vector2() :
		push_error('No subscene found: '+newSubscene)
		return
	subscene = newSubscene
	if changePlayerPosition:
		player.position = playerTargetPosition
	get_parent().localCamera.position = cameraTargetPosition
