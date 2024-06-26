extends Node
class_name DialogueHandler
@onready var dialogueBox = $"Dialogue Box"
@onready var dialogueTextBox = $"Dialogue Box/Dialogue Text Box"

#The text to display
var dialogueText:String:
	set(value):
		dialogueText = value
		#Hides the dialogue box if the text is empty, otherwise shows the box
		if value == "":
			dialogueBox.visible = false
			dialogueTextBox.text = ""
		else:
			dialogueBox.visible = true
		if dialogueText.find('#'):
			if dialogueText.right(8) == '#ADVANCE':
				dialogueText = dialogueText.left(-8)
				call_deferred("advanceScene")
#The current dialoguePos, used to place characters one at a time
var dialoguePos:int


#All cutscenes data
var sceneDict := {
	'cabinScene' = {
		'dialogue': [
			cabinScene
		]
	},
	'meek0' = {
		'dialogue': [
			'"Hey, you\'re back! D-did you find anything cool?"'
		],
		'confidence': 15,
		'tags': ["negative", "meek"]
	},
	'meek1' = {
		'dialogue': [
			'"Oh! You startled me.."'
		],
		'tags': ["meek"]
	},
	'soon0' = {
		'dialogue': [
			'"Hmm, did you forget something?"'
		],
		'tags': ["soon"],
		'confidence': 20
	},
	'soon1' = {
		'dialogue': [
			'"Hey! Are you teasing me?"'
		],
		'tags': ["soon"]
	},
	'cabin0' = {
		'dialogue':[
			'"I... just wanted to say I\'m really glad you\'re here."',
			'"I\'m not very strong, or fast, or brave... I don\'t know how I\'d survive."',
			'"So... thank you."',
			cabin0
		],
		'tags': ["cabin"]
	},
	'cabin0Encourage' = {
		'dialogue':[
			'"Y-you really think so?"'
		]			
	},
	'cabin0Comfort' = {
		'dialogue':[
			'"Well.. thank you."'
		]
	},
	'cabin0Demean' = {
		'dialogue':[
			'"I-I will..."'
		]
	},
	'cabin1' = {
		'dialogue':[
			'"Did you see all the stars that came out tonight?"',
			'"There\'s so many more than I\'ve ever seen... It\'s been that way ever since it happened.."',
			'"I remember my mom calling me a star when I was little."',
			'"I\'m sure she meant that I\'ll shine... but instead, I feel like I\'m drowning among all the other stars in the skies."',
			'"Just another star in the sky..."',
			cabin1
		],
		'tags': ["cabin"]
	},
	'endOfDay' = {
		'dialogue':[
				'"Do you want to have dinner yet?"',
				endOfDayScene
		]
	},
	'fallback' = {
		'dialogue':[
		],
		'tags': ["cabin"]
	},
	'openingCutscene1' = {
		'dialogue': [
			openingCutscene1
		],
		'tags': ["special"]
	},
	'openingCutscene2' = {
		'dialogue': [
			openingCutscene2
		],
		'tags': ["special"]
	},
	'openingItem' = {
		'dialogue': [
			'You pick up the item of yet to be determined nature. It\'s cold in your hand. Probably.',
			openingItem
		]
	},
	'openingCabin' = {
		'dialogue': [
			'"S-stop! Don\'t come any closer!"',
			'"Please... don\'t hurt me..."',
			openingChoice
		],
		'tags': ["cabin"]
	},
	'openingOkay' = {
		'dialogue': [
			'""I-I\'m fine..."',
			openingCont
		]
	},
	'openingNoHurt' = {
		'dialogue': [
			'"R-really...?"',
			openingCont
		]
	},
	'openingLeave' = {
		'dialogue': [
			'"Y-yes, right away! I\'m sorry!"',
			#openingGirlExit
		]
	},
	'openingPanik' = {
		'dialogue': [
			'"I d-don\'t understand what\'s happening... I was just walking by, and there was this huge noise, and everything started shaking..."',
			'"I don\'t know what to do... I\'m so scared..."',
			screenTransitionFadeOut,
			dialogBoxTop.bind(true),
			'[Some time passes as you try to calm her.]',
			screenTransitionFadeIn,
			dialogBoxTop.bind(false),
			'"It sounds like we both need somewhere to sleep... how about here, for now?"',
			'"I can try and fix this place up a bit... and you can try finding us some food and maybe a way off the island!"',
			completeOpening
		]
	}
}

#A signal that tells the world to shake the screen
signal shakeScreen


#These vars are loaded by the save file
var completedScenes := []
var previousCabinDay:int
var previousCabinTime:int
### timeStamp = (day * 1440) + time

#Prevents player from pressing Interact and skipping a cutscene event (not text)
var eventHold := false

#Displays text one character at a time
func _process(_delta):
	if dialogueText != "":
		dialogueTextBox.text = writeText(dialogueText, dialoguePos)
		dialoguePos += 1
		if (dialoguePos >= dialogueText.length()+300) and sceneStarted == "":
			dialogueText = ""

#Current scene
var sceneStarted := ""
#Which line of the scene we're in
var sceneLine := 0
#A signal that tells the world that a scene is playing and to pause player movement
signal scenePause
func startScene(ID:String) -> void:
	print('Starting Scene: '+ID)
	#Checks the sceneDict has the scene
	if !sceneDict.has(ID):
		push_error('Scene not found: '+str(ID))
		return
	print("emit signal")
	#Sets up the scene, then advances it to run the first line.
	scenePause.emit(true)
	sceneStarted = ID
	sceneLine = 0
	advanceScene()

#Runs when the player presses Interact during a scene.
func playerAdvanced() -> void:
	print("player advanced")
	if !eventHold:
		advanceScene()

func advanceScene() -> void:
	if not sceneDict.has(sceneStarted):
		return
	print("Advancing Scene")
	dialogueBox.visible = true
	#Resets scene data and returns, if the sceneLine is bigger than the scene size, I.e. when the scene is over.
	if sceneDict[sceneStarted]['dialogue'].size() < sceneLine+1:
		#print('test')
		scenePause.emit(false)
		sceneStarted = ""
		sceneLine = 0
		dialogueText = ""
		return
	print("sceneLine: "+ str(sceneLine))
	print(sceneDict[sceneStarted]['dialogue'][sceneLine])
	#Checks for an event code, as denoted by ###, then calls that event's corresponding function
	if sceneDict[sceneStarted]['dialogue'][sceneLine] is Callable:
		var event = sceneDict[sceneStarted]['dialogue'][sceneLine]
		dialogueBox.visible = false
		sceneLine += 1
		event.call()
	#Otherwise just displays text as normal
	else:
		dialoguePos = 0
		dialogueText = sceneDict[sceneStarted]['dialogue'][sceneLine]
		sceneLine += 1

#returns a string of text fron the text arg, up to the value given.
func writeText(text: String,value: int) -> String:
	if text.left(value).right(1) == '#' and dialogueText.find('#ADVANCEWHENDONE') != -1:
		dialogueText = dialogueText.right(-15)
		advanceScene()
		text = dialogueText
		return text 
	text = text.left(value)
	return text

#This function gets called by the world node when the player either touches or interacts with a dialogue area, depending on if its a trigger.
#Runs either a scene, if provided, or just displays text.
func processDialogue(nodeDialogueID: String, nodeDialogueText: String) -> void:
	print("Processing Dialogue")
	if nodeDialogueID == "":
		dialogueText = nodeDialogueText
		dialoguePos = 0
	else:
		startScene(nodeDialogueID)

#Utility Function to find the girl Node
func findGirl()->Node:
	var girl 
	print('test3')
	for node in get_tree().get_nodes_in_group("Cutscene Objects"):
		print('test1'+node.name)
		if node.get_meta("cutsceneObjID") == "girl":
			girl = node
			break
	if girl:
		return girl
	else:
		push_error("No girl :(")
		return Node.new()

#Junk code maria doesn't want me to delete >:(
#func test():
	#listValidScenes()
	#eventHold = true
	#var girl := findGirl()
	#var tween = create_tween()
	#tween.tween_property(girl,"position",Vector2(10,10),2)
	#tween.tween_callback(advanceScene)
	#tween.tween_property(self,"eventHold",false,0)
	#tween.tween_property(girl.find_child("dialogueArea"),"sceneID","scene2",0)


#Lists the valid scenes and returns them, based on the scenes required confidence/mood and the Girl's current confidence/mood
func listValidScenes()->Array:
	var validScenes = []
	for scene in sceneDict:
		if checkConfAndMood(scene): validScenes.append(scene)
	if validScenes == []:
		validScenes.append("fallback")
	return validScenes

#Checks both confidence and mood for a given sceneID, returns true if girl's conf/mood is above the scenes requirements
func checkConfAndMood(sceneID:String)->bool:
	var goodConfidence = checkConf(sceneID)
	var goodMood = checkMood(sceneID)
	#print(goodConfidence)
	return goodConfidence and goodMood

#Checks confidence for a given sceneID
func checkConf(sceneID:String)->bool:
	var girl := findGirl()
	var confidence = girl.confidence
	var goodConfidence = true
	if sceneDict[sceneID].has('confidence'):
		if not checkTags(sceneID, "negative"):
			if sceneDict[sceneID]["confidence"] < confidence:
				goodConfidence = false
			pass
		else:
			if sceneDict[sceneID]["confidence"] > confidence:
				goodConfidence = false
	return goodConfidence

#Checks mood for a given sceneID
func checkMood(sceneID:String)->bool:
	var girl := findGirl()
	var mood = girl.mood
	var goodMood = true
	if sceneDict[sceneID].has('mood'):
		if sceneDict[sceneID].has('negative'):
			if sceneDict[sceneID]["mood"] < mood:
				goodMood = false
			pass
		else:
			if sceneDict[sceneID]["mood"] > mood:
				goodMood = false
	return goodMood


#Prompts the player to choose an option, the array is an array of different text options to display, the array index of the choice is returned
func playerDialogueChoice(choices: Array) -> int:
	print("playerDialogueChoice Fired")
	dialogueText = ""
	dialogueBox.visible = true
	var playerChoice:String
	var playerChoices = $"Dialogue Box/Player Choices"
	var labelSettings = LabelSettings.new()
	#labelSettings.font_size = 16
	#Creates a label for each choice, giving it a name that corresponds to the choice's index in the array
	#await get_tree().create_timer(.4).timeout
	for choice in choices:
		var labelNode = Label.new()
		labelNode.text = choice
		labelNode.name = str(choices.find(choice))
		labelNode.label_settings = labelSettings
		print(labelNode.name)
		playerChoices.add_child(labelNode)
	var currentlySelectedChoice = 0
	#Adds a carat to the first choice, as it is selected by default
	playerChoices.get_child(0).text = '> '+playerChoices.get_child(0).text
	#Places the inputHold so that moving to the player choice menu doesn't instantly select a choice.
	playerChoices.inputHold = true
	while true:
		#playerChoices node handles the actual input, sends a signal with the button pressed when recognized.
		var inputResult = await playerChoices.playerChoiceInput
		#Handles the input
		match inputResult:
			"Up": currentlySelectedChoice -= 1
			"Down": currentlySelectedChoice += 1
			"Accept": break
		#Resets the choice text, then adds a carat to the chosen choice
		for choice in choices:
			playerChoices.get_child(choices.find(choice)).text = choice
		playerChoices.get_child(currentlySelectedChoice % 3).text = '> '+choices[currentlySelectedChoice % 3]
	#Removes the choice nodes
	for node in playerChoices.get_children():
		node.queue_free()
	dialogueBox.visible = false
	#Technically redundant since currentlySelectedChoice % 3 is equivalent to the index of the choice, so we could simply just return that.
	playerChoice = choices[currentlySelectedChoice % 3]
	return choices.find(playerChoice)

#Event code for the dialogue trigger in the cabin scene.
func cabinScene():
	var validScenes = listValidScenes()
	var filteredScenes = []
	var previousTimestamp = (previousCabinDay * 1440) + previousCabinTime
	var sceneRoot = get_tree().root.get_node("Cabin")
	var currentTimestamp = (sceneRoot.day * 1440) + sceneRoot.timeOfDay
	var randomScene = ""
	if completedScenes.has("openingCabin"):
		for scene in validScenes:
			if checkTags(scene, "soon") and currentTimestamp - previousTimestamp < 5:
				filteredScenes.append(scene)
			elif checkTags(scene, "meek"):
				filteredScenes.append(scene)
		randomize()
		randomScene = Utility.getRandomArrayMember(filteredScenes)
	else:
		randomScene = "openingCabin"
	print(randomScene)
	startScene(randomScene)

func cabin0():
	completedScenes.append("cabin0")
	var girl := findGirl()
	var choice = await playerDialogueChoice(["You can be strong, too.", "I\'m happy to keep you safe.", "Just make sure you stay useful."])
	match choice:
		0:
			girl.confidence += 10
			startScene("cabin0Encourage")
		1:
			girl.mood += 10
			startScene("cabin0Comfort")
		2:
			girl.confidence -= 10
			girl.mood -= 5
			startScene("cabin0Demean")
	
	
func cabin1():
	completedScenes.append("cabin1")
	advanceScene()

func endOfDayScene():
	var choice =  await playerDialogueChoice(["Yes.", "No, not yet."])
	var filteredScenes = []
	randomize()
	match choice:
		0:
			var scenes = listValidScenes()
			for scene in scenes:
				if checkTags(scene, "cabin") and not completedScenes.has(scene):
					filteredScenes.append(scene)
			var randomScene = Utility.getRandomArrayMember(filteredScenes)
			startScene(randomScene)

func checkTags(sceneID:String, tag:String) -> bool:
	if sceneDict[sceneID].has('tags') and sceneDict[sceneID]["tags"].has(tag):
		return true
	return false

func screenShake(intensity,duration):
	shakeScreen.emit(intensity,duration)

func openingCutscene1():
	print("working")
	var tween = get_tree().create_tween()
	tween.tween_callback(self.screenShake.bind(10,400))
	tween.tween_callback(get_tree().root.get_node("Cliffside Overlook/TileMap/CameraHolder/OverlookCamera/CliffSprite").play.bind("default"))
	advanceScene()

func openingCutscene2():
	print("working")
	var tween = get_tree().create_tween()
	tween.tween_callback(self.screenShake.bind(10,400))
	advanceScene()

func openingItem():
	var openingItemNode:DialogueArea
	var cliffSprite:AnimatedSprite2D
	for node in get_tree().get_nodes_in_group("Cutscene Objects"):
		if node.has_meta("cutsceneObjID") and node.get_meta("cutsceneObjID") == "openingItem":
			openingItemNode = node
			break
	for node in get_tree().get_nodes_in_group("Cutscene Objects"):
		if node.has_meta("cutsceneObjID") and node.get_meta("cutsceneObjID") == "cliffSprite":
			cliffSprite = node
			break
	openingItemNode.sceneID = ""
	cliffSprite.play()
	screenShake(10, 1000)
	advanceScene()

func openingChoice():
	var choice = await playerDialogueChoice(["Are you okay?", "I\'m not going to hurt you.", "Get out, now."])
	match choice:
		0:
			startScene("openingOkay")
		1:
			startScene("openingNoHurt")
		2:
			startScene("openingLeave")

func openingCont():
	startScene("openingPanik")

func completeOpening():
	completedScenes.append("openingCabin")
	advanceScene()

func screenTransitionFadeFull(showDialogueBox = false):
	var fadeNode:AnimationPlayer
	for node in get_tree().get_nodes_in_group("Cutscene Objects"):
		if node.has_meta("cutsceneObjID") and node.get_meta("cutsceneObjID") == "fade":
			fadeNode = node
			break
	var dialogueBoxIndex = dialogueBox.z_index
	if showDialogueBox:
		dialogueBox.visible = true
		dialogueBox.z_index = fadeNode.get_parent().z_index + 1
	else:
		dialogueText = ""
	fadeNode.play("ScreenTransitionFadeOut")
	await fadeNode.get_parent().animation_finished
	fadeNode.play("ScreenTransitionFadeIn")
	await fadeNode.get_parent().animation_finished
	if showDialogueBox:
		dialogueBox.z_index = dialogueBoxIndex
	advanceScene()

func screenTransitionFadeIn(showDialogueBox = false):
	eventHold = true
	var fadeNode:AnimationPlayer
	for node in get_tree().get_nodes_in_group("Cutscene Objects"):
		if node.has_meta("cutsceneObjID") and node.get_meta("cutsceneObjID") == "fade":
			fadeNode = node
			break
	var dialogueBoxIndex = dialogueBox.z_index
	if showDialogueBox:
		dialogueBox.visible = true
		dialogueBox.z_index = fadeNode.get_parent().z_index + 5
	else:
		dialogueText = ""
	fadeNode.play("ScreenTransitionFadeIn")
	await fadeNode.get_parent().animation_finished
	if showDialogueBox:
		dialogueBox.z_index = dialogueBoxIndex
	advanceScene()
	eventHold = false


func screenTransitionFadeOut(showDialogueBox = false):
	print("showDialogueBox: "+ str(showDialogueBox))
	eventHold = true
	var fadeNode:AnimationPlayer
	for node in get_tree().get_nodes_in_group("Cutscene Objects"):
		if node.has_meta("cutsceneObjID") and node.get_meta("cutsceneObjID") == "fade":
			fadeNode = node
			break
	var dialogueBoxIndex = dialogueBox.z_index
	if showDialogueBox:
		dialogueBox.visible = true
		dialogueBox.z_index = fadeNode.get_parent().z_index + 5
	else:
		dialogueText = ""
	fadeNode.play("ScreenTransitionFadeOut")
	await fadeNode.get_parent().animation_finished
	if showDialogueBox:
		dialogueBox.z_index = dialogueBoxIndex
	advanceScene()
	eventHold = false

func dialogBoxTop(status = true):
	var fadeNode:AnimationPlayer
	var dialogueBoxIndex = dialogueBox.z_index
	for node in get_tree().get_nodes_in_group("Cutscene Objects"):
		if node.has_meta("cutsceneObjID") and node.get_meta("cutsceneObjID") == "fade":
			fadeNode = node
			break
	if status:
		dialogueBox.visible = true
		dialogueBox.z_index = fadeNode.get_parent().z_index + 5
	else:
		dialogueText = ""
		dialogueBox.z_index = fadeNode.get_parent().z_index - 5
	advanceScene()
