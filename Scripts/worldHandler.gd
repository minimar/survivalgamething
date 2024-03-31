extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		pauseGame()


func _on_player_dialogue_signal(resultNode:dialogueNode):
	$"UI/Dialogue Handler".processDialogue(resultNode.dialogueID, resultNode.dialogueText)


func pauseGame():
	$UI/PauseMenu.visible = true


