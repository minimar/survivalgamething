extends Node
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
			
#The current dialoguePos, used to place characters one at a time
var dialoguePos:int

#All cutscenes data
var sceneDict := {
	'cabinScene' = {
		'dialogue': [
			'###cabinScene'
		]
	},
	'meek0' = {
		'dialogue': [
			'"Hey, you\'re back! D-did you find anything cool?"'
		],
		'confidence': 15,
		'negative': true
		},
	'meek1' = {
		'dialogue': [
			'"Oh! You startled me.."'
		]},
	'soon0' = {
		'dialogue': [
			'"Hmm, did you forget something?"'
		],
		'confidence': 20
		},
	'soon1' = {
		'dialogue': [
			'"Hey! Are you teasing me?"'
		]},
	'cabin0' = {
		'dialogue':
			[
				'"This should never appear!"'	
			]}
}

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
	#Checks the sceneDict has the scene
	if !sceneDict.has(ID):
		push_error('Scene not found: '+str(ID))
		return
	#Sets up the scene, then advances it to run the first line.
	scenePause.emit(true)
	sceneStarted = ID
	sceneLine = 0
	advanceScene()

#Runs when the player presses Interact during a scene.
func playerAdvanced() -> void:
	if !eventHold:
		advanceScene()

func advanceScene() -> void:
	dialogueBox.visible = true
	#Resets scene data and returns, if the sceneLine is bigger than the scene size, I.e. when the scene is over.
	if sceneDict[sceneStarted]['dialogue'].size() < sceneLine+1:
		scenePause.emit(false)
		sceneStarted = ""
		sceneLine = 0
		dialogueText = ""
		return
	#Checks for an event code, as denoted by ###, then calls that event's corresponding function
	if sceneDict[sceneStarted]['dialogue'][sceneLine].left(3) == "###":
		var event = sceneDict[sceneStarted]['dialogue'][sceneLine].right(-3)
		dialogueBox.visible = false
		call(event)
	#Otherwise just displays text as normal
	else:
		dialogueText = sceneDict[sceneStarted]['dialogue'][sceneLine]
		dialoguePos = 0
	sceneLine += 1

#returns a string of text fron the text arg, up to the value given.
func writeText(text: String,value: int) -> String:
	text = text.left(value)
	return text

#This function gets called by the world node when the player either touches or interacts with a dialogue area, depending on if its a trigger.
#Runs either a scene, if provided, or just displays text.
func processDialogue(nodeDialogueID: String, nodeDialogueText: String) -> void:
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
	var girl := findGirl()
	var validScenes = []
	for scene in sceneDict:
		if checkConfAndMood(scene): validScenes.append(scene)
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
		if sceneDict[sceneID].has('negative'):
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
	dialogueBox.visible = true
	var playerChoice:String
	var playerChoices = $"Dialogue Box/Player Choices"
	var labelSettings = LabelSettings.new()
	#labelSettings.font_size = 16
	#Creates a label for each choice, giving it a name that corresponds to the choice's index in the array
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
	for scene in validScenes:
		if scene.contains("soon") or scene.contains("meek"):
			filteredScenes.append(scene)
	randomize()
	var randomScene = Utility.getRandomArrayMember(filteredScenes)
	print(randomScene)
	startScene(randomScene)
