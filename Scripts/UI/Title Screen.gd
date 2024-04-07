extends Control

var latestSave
# Called when the node enters the scene tree for the first time.
func _ready():
	for button in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		button.get_node("Label").text = button.name
		button.pressed.connect(_on_button_pressed.bind(button))
	for button in $"New Game Confirmation/MarginContainer/VBoxContainer".get_children():
		if button is TextureButton: 
			button.get_node("Label").text = button.name
			button.pressed.connect(_on_new_game_confirmation_button_pressed.bind(button))
	latestSave = {}
	if Utility.getLatestSave():
		$"PanelContainer/MarginContainer/VBoxContainer/Load Game".visible = true


func _on_new_game_confirmation_button_pressed(button: TextureButton):
	match button.name:
		"Yes": startNewGame()
		"No": $"New Game Confirmation".visible = false

func _on_button_pressed(button: TextureButton):
	match button.name:
		"New Game": checkNewGame()
		"Load Game": loadGame()
		"Options": pass
		"Exit Game": get_tree().quit()

func checkNewGame():
	if Utility.getLatestSave():
		$"New Game Confirmation".visible = true
	else:
		startNewGame()

func startNewGame():
	if Utility.getLatestSave():
		var dir = DirAccess.open("user://")
		if FileAccess.file_exists("user://save.sav"):
			dir.remove("save.sav")
		if dir.dir_exists("Manual Saves"):
			if dir.dir_exists("Backup Saves"):
				dir.change_dir("Backup Saves")
				for file in dir.get_files():
					dir.remove(file)
				dir.change_dir("user://")
				dir.remove("Backup Saves")
			dir.make_dir("Backup Saves")
			dir.change_dir("Manual Saves")
			for file in dir.get_files():
				print("hskjskdkshdsahk"+file)
				dir.copy("user://Manual Saves/"+file,"user://Backup Saves/"+file)
				dir.remove(file)
			dir.change_dir("user://")
			dir.remove("Manual Saves")
	
	SceneSwitcher.changeScene("res://Scenes/overworld.tscn",Vector2(0,0))

func loadGame():
	var saveDict = Utility.getLatestSave()
	if saveDict.has("player"):
		if saveDict["player"].has("playerCurrentScene"):
			SceneSwitcher.changeScene(saveDict["player"]["playerCurrentScene"],str_to_var("Vector2"+saveDict["player"]["position"]))
