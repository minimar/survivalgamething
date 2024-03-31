extends Node
@onready var dialogueBox = $"Dialogue Box"
var dialogueText:String
var dialoguePos:int

func _process(delta):
	dialogueBox.text = writeText(dialogueText, dialoguePos)
	dialoguePos += 1

func dialogBox(ID):
	pass

func writeText(text,value):
	text = text.left(value)
	return text
	
func processDialogue(nodeDialogueID, nodeDialogueText):
	if nodeDialogueID == "":
		dialogueText = nodeDialogueText
		dialoguePos = 0
