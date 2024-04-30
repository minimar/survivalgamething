extends VBoxContainer

var inputResult
signal playerChoiceInput
var inputHold = true
func _process(_delta):
	if get_children():
		if Input.is_action_just_pressed("Up"):
			playerChoiceInput.emit("Up")
			inputResult = "Up"
		if Input.is_action_just_pressed("Down"):
			playerChoiceInput.emit("Down")
			inputResult = "Down"
		if Input.is_action_just_pressed("Interact"):
			#Prevents moving to the choice menu from activating a choice
			if inputHold:
				inputHold = false
				return
			inputResult = "Accept"
			playerChoiceInput.emit("Accept")
