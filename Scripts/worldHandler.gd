extends Node2D

var timeOfDay = 540
var day = 1
var weather = "Clear"
const weatherTypes = ["Clear","Rain","PostRain"]


var player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_child("Player")
	loadUniversal()
	loadScene()
	#Connect Player Signals
	player.dialogueSignal.connect(_on_player_dialogue_signal)
	player.showGenericText.connect(_on_player_show_generic_text)
	player.advanceScene.connect(_on_player_advance_scene)
	print(error_string(player.updateInv.connect(_on_player_update_inv)))
	$"UI/Dialogue Handler".scenePause.connect(_on_dialogue_scene_pause)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		pauseGame()
	if Input.is_action_just_pressed("Inventory"):
		showInv()

func _on_dialogue_scene_pause(pause):
	player.scenePause = pause

func _on_player_advance_scene():
	$"UI/Dialogue Handler".playerAdvanced()

func _on_player_dialogue_signal(resultNode:dialogueNode):
	$"UI/Dialogue Handler".processDialogue(resultNode.dialogueID, resultNode.dialogueText)

func _on_player_show_generic_text(text):
	$"UI/Dialogue Handler".dialogueText = text
	$"UI/Dialogue Handler".dialoguePos = 0

func _on_player_update_inv(items):
	print('update signal')
	$"UI/Inventory".items = items

func pauseGame():
	$UI/PauseMenu.visible = true


func showInv():
	$UI/Inventory.visible = !$UI/Inventory.visible

func saveUniversal():
	var saveFile
	var saveDict
	if FileAccess.file_exists("user://save.sav"):
		saveFile = FileAccess.open("user://save.sav",FileAccess.READ)
		print(saveFile.get_open_error())
		saveDict = JSON.parse_string(saveFile.get_line())
		saveFile.close()
	else:
		saveDict = {}
	
	saveDict["player"] = {
		"health": player.health,
		"hunger": player.hunger,
		"items": player.items,
		"bulletsInGun": player.bulletsInGun,
		"outfit": player.outfit
	}
	saveDict["world"] = {
		"timeOfDay": timeOfDay,
		"day": day,
		"weather": weather
	}
	saveFile = FileAccess.open("user://save.sav",FileAccess.WRITE)
	print('test2 '+ error_string(saveFile.get_open_error()))
	saveFile.store_string(JSON.stringify(saveDict))
	saveFile.flush()
	saveFile.close()

func loadUniversal():
	if !FileAccess.file_exists("user://save.sav"):
		return
	var saveFile = FileAccess.open("user://save.sav",FileAccess.READ)
	var saveDict = JSON.parse_string(saveFile.get_line())
	for i in ['timeOfDay','weather','day']:
		match i:
			'timeOfDay': timeOfDay = saveDict['world'][i]
			'weather': weather = saveDict['world'][i]
			'day': day = saveDict['world'][i]
	for i in ['health','hunger','items','bulletsInGun','outfit']:
		match i:
			'health': player.health = saveDict["player"][i]
			'hunger': player.hunger = saveDict["player"][i]
			'items': player.items = saveDict["player"][i]
			'bulletsInGun': player.bulletsInGun = saveDict["player"][i]
			'outfit': player.outfit = saveDict["player"][i]

func saveScene():
	var currentScene = get_tree().get_current_scene()
	var saveFile
	var saveDict
	if FileAccess.file_exists("user://save.sav"):
		saveFile = FileAccess.open("user://save.sav",FileAccess.READ)
		print(saveFile.get_open_error())
		saveDict = JSON.parse_string(saveFile.get_line())
		saveFile.close()
	else:
		saveDict = {}
	saveDict[currentScene] = {}
	for container in get_tree().get_nodes_in_group("Containers"):
		saveDict[currentScene][container.name] = {
			"node": container,
			"containerOpened": container.containerOpened
		}
	saveFile = FileAccess.open("user://save.sav",FileAccess.WRITE)
	saveFile.store_string(JSON.stringify(saveDict))
	saveFile.flush()
	saveFile.close()

func loadScene():
	if !FileAccess.file_exists("user://save.sav"):
		return
	var saveFile = FileAccess.open("user://save.sav",FileAccess.READ)
	var saveDict = JSON.parse_string(saveFile.get_line())
	if !saveDict.has(get_tree().get_current_scene()):
		return
	var containers = get_tree().get_nodes_in_group("Containers")
	for key in saveDict[get_tree().get_current_scene()]:
		for container in containers:
			if saveDict[get_tree().get_current_scene()][key]['node'] == container:
				container.containerOpened = saveDict[get_tree().get_current_scene()][key]['containerOpened']
				containers.erase(container)
