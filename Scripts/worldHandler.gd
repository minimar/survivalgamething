extends Node2D

var timeOfDay = 540
var day = 1
var weather = "clear"
const weatherTypes = ["clear","rain","postRain"]
@export var minuteLengthInSeconds:= 10.0
@export var oddsOfRain := 4


@onready var sceneSwitcher = $"/root/SceneSwitcher"



var player
var minuteCountdown = minuteLengthInSeconds

var warpCoordinates: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_child("Player")
	warpCoordinates = $"/root/SceneSwitcher".getWarpCoordinates()
	if warpCoordinates != Vector2():
		player.global_position = warpCoordinates
	loadUniversal()
	loadScene()
	#Connect Player Signals
	player.dialogueSignal.connect(_on_player_dialogue_signal)
	player.showGenericText.connect(_on_player_show_generic_text)
	player.advanceScene.connect(_on_player_advance_scene)
	print(error_string(player.updateInv.connect(_on_player_update_inv)))
	$"UI/Dialogue Handler".scenePause.connect(_on_dialogue_scene_pause)
	
	for areaWarp in get_tree().get_nodes_in_group("Area Warps"):
		areaWarp.changeScene.connect(changeScene)


func changeScene(targetScene,newWarpCoordinates):
	saveScene()
	saveUniversal()
	sceneSwitcher.changeScene(targetScene,newWarpCoordinates)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		pauseGame()
	if Input.is_action_just_pressed("Inventory"):
		showInv()
	minuteCountdown -= delta
	if minuteCountdown <= 0:
		timeOfDay += 1
		minuteCountdown = minuteLengthInSeconds
		if timeOfDay >= 1440:
			timeOfDay = 0
			day += 1
			if weather == 'rain':
				weather = 'postRain'
			else:
				if randi_range(1,oddsOfRain) == 1:
					weather = 'rain'
				else:
					weather = 'clear'

func _on_dialogue_scene_pause(pause):
	player.scenePause = pause

func _on_player_advance_scene():
	$"UI/Dialogue Handler".playerAdvanced()

func _on_player_dialogue_signal(resultNode:dialogueNode):
	$"UI/Dialogue Handler".processDialogue(resultNode.dialogueID, resultNode.dialogueText)

func _on_player_show_generic_text(text):
	$"UI/Dialogue Handler".dialogueText = text
	$"UI/Dialogue Handler".dialoguePos = 0

func _on_player_update_inv(inv:Array):
	print('update signal')
	$"UI/Inventory".items = inv[0]
	$"UI/Inventory".outfit = inv[1]
	$"UI/Inventory".hasGun = inv[2]
	$"UI/Inventory".bullets = inv[3]

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
		"bulletsInGun": player.bulletsInGun,
		"hasGun": player.hasGun,
		"items": {},
		"outfit": {}
	}
	if player.bullets:
		saveDict["player"]["bullets"] = player.bullets.quantity
	var slotCount = 0
	for item in player.items:
		saveDict["player"]["items"][item.itemID+'-'+str(slotCount)] = item.quantity
		slotCount += 1
	print(player.outfit)
	for outfitPiece in player.outfit:
		print(outfitPiece)
		saveDict["player"]["outfit"][outfitPiece.itemID] = 1
	
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
	for i in ['health','hunger','bulletsInGun','outfit','hasGun']:
		match i:
			'health': player.health = saveDict["player"][i]
			'hunger': player.hunger = saveDict["player"][i]
			'bulletsInGun': player.bulletsInGun = saveDict["player"][i]
			'hasGun': player.hasGun = saveDict["player"][i]
	if saveDict["player"].has('items'):
		for item in saveDict["player"]["items"]:
			var itemName = item.erase(item.find('-'),3)
			print(itemName)
			var newItem = $"/root/ItemGenerator".makeItem(itemName)
			newItem.quantity = saveDict["player"]["items"][item]
			player.items.append(newItem)
	if saveDict["player"].has('outfit'):
		for outfitPiece in saveDict["player"]["outfit"]:
			var newItem = $"/root/ItemGenerator".makeItem(outfitPiece)
			player.outfit.append(newItem)
	if saveDict["player"].has('bullets'):
		var newItem = $"/root/ItemGenerator".makeItem('bullet')
		newItem.quantity = saveDict["player"]["bullets"]
		player.bullets = newItem
	player.sortOutfit()

func saveScene():
	print("SAVING SCENE")
	var currentScene = get_tree().get_current_scene().name
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
	print("Containers: "+str(get_tree().get_nodes_in_group("Containers")))
	for container in get_tree().get_nodes_in_group("Containers"):
		saveDict[currentScene][container.containerID] = {
			"containerID": container.containerID,
			"containerOpened": container.containerOpened
		}
	saveFile = FileAccess.open("user://save.sav",FileAccess.WRITE)
	saveFile.store_string(JSON.stringify(saveDict))
	saveFile.flush()
	saveFile.close()


func loadScene():
	print("LOADING SCENE")
	if !FileAccess.file_exists("user://save.sav"):
		return
	var currentScene = get_tree().get_current_scene().name
	var saveFile = FileAccess.open("user://save.sav",FileAccess.READ)
	var saveDict = JSON.parse_string(saveFile.get_line())
	if !saveDict.has(currentScene):
		print("Save Dict does not have scene-specific data.")
		return
	var containers = get_tree().get_nodes_in_group("Containers")
	print(saveDict[currentScene])
	for key in saveDict[currentScene]:
		print("Searching for: "+key)
		for container in containers:
			if saveDict[currentScene][key]['containerID'] == container.containerID:
				print('Container found.')
				container.containerOpened = saveDict[currentScene][key]['containerOpened']
				containers.erase(container)
