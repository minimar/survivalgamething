extends Node

var warpCoordinates = Vector2()
var subScene := ""

var elevatorID: String
var elevatorFloor: int

func changeScene(targetScene: String,newWarpCoordinates := Vector2(0,0), newSubScene := ""):
	get_tree().call_deferred("change_scene_to_file",targetScene)
	warpCoordinates = newWarpCoordinates
	subScene = newSubScene

func getWarpCoordinates():
	return warpCoordinates
