extends Area2D
class_name AreaWarp

@export var warpCoordinates: Vector2
@export_file("*.tscn") var targetScene
@export var subScene: String


signal changeScene
func _ready():
	if not (targetScene):
		printerr('Area Warp: '+name+' is missing target scene.')
	add_to_group("Area Warps")

func _on_player_entered(_player:Player):
	changeScene.emit(targetScene,warpCoordinates,subScene)
