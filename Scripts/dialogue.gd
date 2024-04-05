extends Node
@onready var dialogueBox = $"Dialogue Box"
@onready var dialogueTextBox = $"Dialogue Box/Dialogue Text Box"

var dialogueText:String:
	set(value):
		dialogueText = value
		if value == "":
			dialogueBox.visible = false
			dialogueTextBox.text = ""
		else:
			dialogueBox.visible = true
			
var dialoguePos:int

var sceneDict = {
	'cabinScene' = {
		'dialogue': [
			'###cabinScene'
		]
	},
	'meek0' = {
		'dialogue': [
			'"Hey, you\'re back! D-did you find anything cool?"'
		]},
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
		]}
}

var completedScenes = []

var eventHold = false

func _process(_delta):
	if dialogueText != "":
		dialogueTextBox.text = writeText(dialogueText, dialoguePos)
		dialoguePos += 1
		if (dialoguePos >= dialogueText.length()+300) and sceneStarted == "":
			dialogueText = ""

var sceneStarted = ""
var sceneLine = 0
signal scenePause
func startScene(ID):
	#print('Help me: '+str(sceneDict.has(ID)))
	if !sceneDict.has(ID):
		push_error('Scene not found: '+str(ID))
		return
	#print('test')
	scenePause.emit(true)
	sceneStarted = ID
	sceneLine = 0
	advanceScene()

func playerAdvanced():
	if !eventHold:
		advanceScene()

func advanceScene():
	dialogueBox.visible = true
	print(sceneDict[sceneStarted]['dialogue'].size())
	if sceneDict[sceneStarted]['dialogue'].size() < sceneLine+1:
		scenePause.emit(false)
		sceneStarted = ""
		sceneLine = 0
		dialogueText = ""
		return
	if sceneDict[sceneStarted]['dialogue'][sceneLine].left(3) == "###":
		var event = sceneDict[sceneStarted]['dialogue'][sceneLine].right(-3)
		dialogueBox.visible = false
		call(event)
	else:
		dialogueText = sceneDict[sceneStarted]['dialogue'][sceneLine]
		dialoguePos = 0
	sceneLine += 1

func writeText(text,value):
	text = text.left(value)
	return text
	
func processDialogue(nodeDialogueID, nodeDialogueText):
	if nodeDialogueID == "":
		dialogueText = nodeDialogueText
		dialoguePos = 0
	else:
		startScene(nodeDialogueID)
		
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

func test():
	listValidScenes()
	#eventHold = true
	#var girl := findGirl()
	#var tween = create_tween()
	#tween.tween_property(girl,"position",Vector2(10,10),2)
	#tween.tween_callback(advanceScene)
	#tween.tween_property(self,"eventHold",false,0)
	#tween.tween_property(girl.find_child("dialogueArea"),"sceneID","scene2",0)

func listValidScenes()->Array:
	var girl := findGirl()
	var validScenes = []
	for key in sceneDict:
		if checkConfAndMood(key): validScenes.append(key)
	return validScenes


func checkConfAndMood(key:String)->bool:
	var goodConfidence = checkConf(key)
	var goodMood = checkMood(key)
	print(goodConfidence)
	return goodConfidence and goodMood

func checkConf(key:String)->bool:
	var girl := findGirl()
	var confidence = girl.confidence
	var goodConfidence = true
	if sceneDict[key].has('confidence'):
		if sceneDict[key]["confidence"] > confidence:
			goodConfidence = false
	return goodConfidence

func checkMood(key:String)->bool:
	var girl := findGirl()
	var mood = girl.mood
	var goodMood = true
	if sceneDict[key].has('mood'):
		if sceneDict[key]["mood"] > mood:
			goodMood = false
	return goodMood

func getRandomScene(scenes: Array) -> String:
	return scenes[randi_range(0,scenes.size()-1)]

func playerDialogueChoice(choices: Array) -> String:
	dialogueBox.visible = true
	var playerChoice:String
	var playerChoices = $"Dialogue Box/Player Choices"
	var labelSettings = LabelSettings.new()
	#labelSettings.font_size = 16
	for choice in choices:
		var labelNode = Label.new()
		labelNode.text = choice
		labelNode.name = str(choices.find(choice))
		labelNode.label_settings = labelSettings
		print(labelNode.name)
		playerChoices.add_child(labelNode)
	var currentlySelectedChoice = 0
	playerChoices.get_child(0).text = '> '+playerChoices.get_child(0).text
	while true:
		var inputResult = await playerChoices.playerChoiceInput
		match inputResult:
			"Up": currentlySelectedChoice -= 1
			"Down": currentlySelectedChoice += 1
			"Accept": break
		for choice in choices:
			playerChoices.get_child(choices.find(choice)).text = choice
		print(choices)
		print(choices.find(currentlySelectedChoice % 3))
		print(currentlySelectedChoice)
		print(choices[choices.find(currentlySelectedChoice % 3)])
		playerChoices.get_child(currentlySelectedChoice % 3).text = '> '+choices[currentlySelectedChoice % 3]
	for node in playerChoices.get_children():
		node.queue_free()
	dialogueBox.visible = false
	playerChoice = choices[currentlySelectedChoice % 3]
	return playerChoice


func cabinScene():
	var validScenes = listValidScenes()
	var randomScene = getRandomScene(validScenes)
	var choice = await playerDialogueChoice(['test1','test2','test3'])
	print('choice: ' + choice)
	#startScene(randomScene)
