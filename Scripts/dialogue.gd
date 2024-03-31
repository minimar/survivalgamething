extends Node
@onready var dialogueBox = $"Dialogue Box"
var dialogueText:String:
	set(value):
		dialogueText = value
		if value == "":
			$"TileMap".visible = false
			dialogueBox.text = ""
		else:
			$"TileMap".visible = true
			
var dialoguePos:int

var sceneDict = {
	'scene1' = {
		'dialogue': [
			'Line1',
			'###scriptedEventCode',
			'Line2'
		],
		'scriptedEventCode': []
	}
}



func _process(delta):
	if dialogueText != "":
		dialogueBox.text = writeText(dialogueText, dialoguePos)
		dialoguePos += 1
		if (dialoguePos >= dialogueText.length()+300) and sceneStarted == "":
			dialogueText = ""

var sceneStarted = ""
var sceneLine = 0
signal scenePause
func startScene(ID):
	if !sceneDict.has(ID):
		printerr('Scene not found: '+str(ID))
	print('test')
	scenePause.emit(true)
	sceneStarted = ID
	sceneLine = 0
	advanceScene()

func playerAdvanced():
	advanceScene()

func advanceScene():
	print(sceneDict[sceneStarted]['dialogue'].size())
	if sceneDict[sceneStarted]['dialogue'].size() < sceneLine+1:
		scenePause.emit(false)
		sceneStarted = ""
		sceneLine = 0
		dialogueText = ""
		return
	if sceneDict[sceneStarted]['dialogue'][sceneLine].left(3) == "###":
		pass
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
