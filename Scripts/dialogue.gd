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
	'scene1' = {
		'dialogue': [
			'test'
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
		'confidence':
			[
				20
			]
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
	for node in get_tree().get_nodes_in_group("Cutscene Objects"):
		if node.get_meta("cutsceneObjID") == "girl":
			girl = node
			break
	if girl:
		return girl
	else:
		push_error("No girl :(")
		return Node.new()

func test():
	evalDialogue()
	#eventHold = true
	#var girl := findGirl()
	#var tween = create_tween()
	#tween.tween_property(girl,"position",Vector2(10,10),2)
	#tween.tween_callback(advanceScene)
	#tween.tween_property(self,"eventHold",false,0)
	#tween.tween_property(girl.find_child("dialogueArea"),"sceneID","scene2",0)

func evalDialogue():
	var girl := findGirl()
	var tween = create_tween()
	var mood = girl.mood
	var confidence = girl.confidence
	for scenes in sceneDict:
		var sceneList = scenes[confidence]
		print(sceneList)
