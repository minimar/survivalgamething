extends Node2D
class_name SubsceneHandler

var player
var subScene: String
var cityInteriorSubScenes = {
	"apartmentBuilding1": {
		"player": Vector2(64,93),
		"camera": Vector2(0,0)
	},
	"apartmentBuilding1A": {
		"player": Vector2(),
		"camera": Vector2()
	}
}

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	


func changeSubScene(newSubScene,changePlayerPosition = false):
	subScene = newSubScene
	var playerTargetPosition
	var cameraTargetPosition
	if cityInteriorSubScenes.has(newSubScene):
		if cameraTargetPosition:
			push_error("TWO DICTS, SAME SUBSCENE ID: cityInteriorSubScenes")
		
		cameraTargetPosition = cityInteriorSubScenes[newSubScene]["camera"]
		playerTargetPosition = cityInteriorSubScenes[newSubScene]["player"]
		
	#ADD NEW SUBSCENE DICTS HERE
	
	if changePlayerPosition:
		player.position = playerTargetPosition
	get_parent().localCamera.position = cameraTargetPosition
