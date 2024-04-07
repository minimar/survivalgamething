extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		button.get_node("Label").text = button.name
		button.pressed.connect(_on_button_pressed.bind(button))

func _on_button_pressed(button: TextureButton):
	match button.name:
		"Try Again":
			var saveDict = Utility.getLatestSave()
			if saveDict.has("player"):
				if saveDict["player"].has("playerCurrentScene"):
					SceneSwitcher.changeScene(saveDict["player"]["playerCurrentScene"],str_to_var("Vector2"+saveDict["player"]["position"]))
		"Exit Game":
			SceneSwitcher.changeScene("res://Scenes/title_screen.tscn")
