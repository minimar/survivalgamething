extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_parent().ready
	if SceneSwitcher.warpCoordinates != Vector2():
		get_parent().startScene("openingCutscene2")

