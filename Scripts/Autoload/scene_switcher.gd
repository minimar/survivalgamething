extends Node

var warpCoordinates = Vector2()

func changeScene(targetScene,newWarpCoordinates):
	get_tree().call_deferred("change_scene_to_file",targetScene)
	warpCoordinates = newWarpCoordinates
	

func getWarpCoordinates():
	return warpCoordinates
