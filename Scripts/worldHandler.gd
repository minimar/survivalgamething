extends Node2D

var timeOfDay := 1100
var day = 1
var weather = "clear"
const weatherTypes = ["clear","rain","postRain"]
@export var minuteLengthInSeconds := 10.0


@export var oddsOfRain := 4

@onready var dialogueHandler = $"UI/Dialogue Handler"
@onready var sceneSwitcher = $"/root/SceneSwitcher"
@onready var pauseMenu = $UI/PauseMenu
@onready var inventoryUI = $UI/Inventory
@onready var itemGenerator = $"/root/ItemGenerator"
@onready var player = find_child("Player")
var nightShader



var minuteCountdown = .01

var warpCoordinates: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if name == 'Overworld':
		nightShader = player.find_child("Camera2D").find_child('nightShader')
	
	if spawnEnemies:
		spawnDailyEnemies()
	warpCoordinates = sceneSwitcher.getWarpCoordinates()
	if warpCoordinates != Vector2():
		player.global_position = warpCoordinates
	loadUniversal()
	loadScene()
	#Connect Player Signals
	player.dialogueSignal.connect(_on_player_dialogue_signal)
	player.showGenericText.connect(_on_player_show_generic_text)
	player.advanceScene.connect(_on_player_advance_scene)
	print(error_string(player.updateInv.connect(_on_player_update_inv)))
	dialogueHandler.scenePause.connect(_on_dialogue_scene_pause)
	
	for areaWarp in get_tree().get_nodes_in_group("Area Warps"):
		areaWarp.changeScene.connect(changeScene)


func changeScene(targetScene,newWarpCoordinates):
	saveScene()
	saveUniversal()
	sceneSwitcher.changeScene(targetScene,newWarpCoordinates)

var sunsetStarted = false:
	set(value):
		sunsetStarted = value
		if sunsetStarted:
			nightStarted = !value
			sunriseStarted = !value
var nightStarted = false:
	set(value):
		nightStarted = value
		if nightStarted:
			sunsetStarted = !value
			sunriseStarted = !value
var sunriseStarted = false:
	set(value):
		sunriseStarted = value
		if sunriseStarted:
			sunsetStarted = !value
			nightStarted = !value
		


const startOfSunset = 1140
const startOfNight = 1240
const startOfSunrise = 390
const startOfDay = 490
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		pauseGame()
	if Input.is_action_just_pressed("Inventory"):
		showInv()
	minuteCountdown -= delta
	#print(nightShader.modulate)
	if minuteCountdown <= 0:
		#print(timeOfDay)
		timeOfDay += 1
		minuteCountdown = minuteLengthInSeconds
		if timeOfDay % 60 == 0:
			player.hunger -= 4
		if (timeOfDay >= startOfSunset && timeOfDay < startOfNight) and nightShader and !sunsetStarted:
			sunsetStarted = true
			var sunsetTween = create_tween()
			var timeProgressedInSunset = float(timeOfDay-startOfSunset)
			if timeProgressedInSunset <= 30:
				print('Start of Sunset Block')
				const opacityUnitsPerMinute = 2.33333
				print('Opacity: '+str(opacityUnitsPerMinute*timeProgressedInSunset))
				print(timeProgressedInSunset)
				nightShader.modulate = Color8(190,78,0,int(opacityUnitsPerMinute*timeProgressedInSunset))
				print(str(minuteLengthInSeconds))
				print('Time of first tween: '+ str(minuteLengthInSeconds*(30-timeProgressedInSunset)))
				
				sunsetTween.tween_property(nightShader, "modulate", Color8(190,78,0,70), int(minuteLengthInSeconds*(30-timeProgressedInSunset)))
				if player.hasLantern:
					sunsetTween.tween_property(nightShader,"frame",1,0.1)
					sunsetTween.tween_callback(player.find_child('Lantern').set_visible.bind(true))
				sunsetTween.tween_property(nightShader, "modulate", Color8(0,10,72,170), minuteLengthInSeconds*70)
			else:
				const opacityUnitsPerMinute = 1.42857
				const redUnitsPerMinute = 2.57143
				const greenUnitsPerMinute = 0.971429
				const blueUnitsPerMinute = 1.02857
				nightShader.modulate = Color8(int(190-(redUnitsPerMinute*(timeProgressedInSunset-30))),int(78-(greenUnitsPerMinute*(timeProgressedInSunset-30))),int(blueUnitsPerMinute*(timeProgressedInSunset-30)),int(70+(opacityUnitsPerMinute*(timeProgressedInSunset-30))))
				if player.hasLantern:
					sunsetTween.tween_property(nightShader,"frame",1,0.1)
					sunsetTween.tween_callback(player.find_child('Lantern').set_visible.bind(true))
				sunsetTween.tween_property(nightShader, "modulate", Color8(0,10,72,170), minuteLengthInSeconds*(100-timeProgressedInSunset))
		if ((timeOfDay >= startOfNight && timeOfDay <= 1440) or (timeOfDay >= 0 && timeOfDay < startOfSunrise)) and nightShader and !nightStarted:
			nightStarted = true
			nightShader.modulate = Color8(0,10,72,170)
			if player.hasLantern:
				player.find_child('Lantern').visible = true
		if (timeOfDay >= startOfSunrise && timeOfDay < startOfDay) and nightShader and !sunriseStarted:
			sunriseStarted = true
			var sunsetTween = create_tween()
			var timeProgressedInSunrise = float(timeOfDay-startOfSunrise)
			if timeProgressedInSunrise <= 70:
				const opacityUnitsPerMinute = 1.42857
				const redUnitsPerMinute = 2.57143
				const greenUnitsPerMinute = 0.971429
				const blueUnitsPerMinute = 1.02857
				nightShader.modulate = Color8(int(0+(redUnitsPerMinute*(timeProgressedInSunrise))),int(10+(greenUnitsPerMinute*(timeProgressedInSunrise))),int(72-blueUnitsPerMinute*(timeProgressedInSunrise)),int(170-(opacityUnitsPerMinute*(timeProgressedInSunrise))))
				sunsetTween.tween_property(nightShader, "modulate", Color8(190,78,0,70), minuteLengthInSeconds*(70-timeProgressedInSunrise))
				if player.hasLantern:
					sunsetTween.tween_property(nightShader,"frame",0,0.1)
					sunsetTween.tween_callback(player.find_child('Lantern').set_visible.bind(false))
				sunsetTween.tween_property(nightShader, "modulate", Color8(190,78,0,0), minuteLengthInSeconds*70)
			else:
				print('Start of Sunset Block')
				const opacityUnitsPerMinute = 2.33333
				print('Opacity: '+str(opacityUnitsPerMinute*timeProgressedInSunrise-70))
				print(timeProgressedInSunrise)
				nightShader.modulate = Color8(190,78,0,70-int(opacityUnitsPerMinute*timeProgressedInSunrise-70))
				print(str(minuteLengthInSeconds))
				print('Time of first tween: '+ str(minuteLengthInSeconds*(100-timeProgressedInSunrise)))
				if player.hasLantern:
					sunsetTween.tween_property(nightShader,"frame",0,0.1)
					sunsetTween.tween_callback(player.find_child('Lantern').set_visible.bind(false))
				sunsetTween.tween_property(nightShader, "modulate", Color8(190,78,0,0), int(minuteLengthInSeconds*(100-timeProgressedInSunrise)))
		if timeOfDay > startOfDay:
			if player.hasLantern:
				player.find_child('Lantern').visible = false
		if timeOfDay >= 1440:
			timeOfDay = 0
			day += 1
			spawnEnemies = true
			spawnDailyEnemies()
			if weather == 'rain':
				weather = 'postRain'
			else:
				if randi_range(1,oddsOfRain) == 1:
					weather = 'rain'
				else:
					weather = 'clear'
var spawnEnemies = true
func spawnDailyEnemies():
	if find_child("Biomes"):
		var biomes = $Biomes.get_children()
		for Biome in biomes:
			spawnBiomeEnemies(Biome)
		spawnEnemies = false

func spawnBiomeEnemies(Biome:biome):
	var playerExclusionArea = player.find_child("SpawnExclusionArea").polygon
	var biomeArea = Biome.find_child("CollisionPolygon2D").polygon
	biomeArea = Geometry2D.clip_polygons(biomeArea,playerExclusionArea)
	if !biomeArea:
		return
	if Biome.biomeName == 'cabinForest':
		print('help')
		$testPolygon.polygon = biomeArea
	
func _on_dialogue_scene_pause(pause):
	player.scenePause = pause

func _on_player_advance_scene():
	dialogueHandler.playerAdvanced()

func _on_player_dialogue_signal(resultNode:dialogueArea):
	print('test: ' + resultNode.sceneID)
	dialogueHandler.processDialogue(resultNode.sceneID, resultNode.dialogueText)

func _on_player_show_generic_text(text):
	dialogueHandler.dialogueText = text
	dialogueHandler.dialoguePos = 0

func _on_player_update_inv(inv:Array):
	print('update signal')
	inventoryUI.items = inv[0]
	inventoryUI.outfit = inv[1]
	inventoryUI.hasGun = inv[2]
	inventoryUI.bullets = inv[3]

func pauseGame():
	pauseMenu.visible = true


func showInv():
	inventoryUI.visible = !inventoryUI.visible

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
	#Dialogue
	saveDict["dialogueHandler"] = {
		"completedScenes": dialogueHandler.completedScenes
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
	
	for key in saveDict['world']:
		match key:
			'timeOfDay': timeOfDay = saveDict['world'][key]
			'weather': weather = saveDict['world'][key]
			'day': day = saveDict['world'][key]
	for key in saveDict["player"]:
		match key:
			'health': player.health = saveDict["player"][key]
			'hunger': player.hunger = saveDict["player"][key]
			'bulletsInGun': player.bulletsInGun = saveDict["player"][key]
			'hasGun': player.hasGun = saveDict["player"][key]
	if saveDict["player"].has('items'):
		for item in saveDict["player"]["items"]:
			var itemName = item.erase(item.find('-'),3)
			print(itemName)
			var newItem = itemGenerator.makeItem(itemName)
			newItem.quantity = saveDict["player"]["items"][item]
			player.items.append(newItem)
	if saveDict["player"].has('outfit'):
		for outfitPiece in saveDict["player"]["outfit"]:
			var newItem = itemGenerator.makeItem(outfitPiece)
			player.outfit.append(newItem)
	if saveDict["player"].has('bullets'):
		var newItem = itemGenerator.makeItem('bullet')
		newItem.quantity = saveDict["player"]["bullets"]
		player.bullets = newItem
	player.sortOutfit()
	#Dialogue Handler
	if saveDict.has("dialogueHandler"):
		for key in saveDict["dialogueHandler"]:
			match key:
				'completedScenes': dialogueHandler.completedScenes = saveDict["dialogueHandler"][key]

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
