extends VBoxContainer

var inputResult
signal playerChoiceInput
func _process(_delta):
	if get_children():
		if Input.is_action_just_pressed("Up"):
			playerChoiceInput.emit("Up")
			inputResult = "Up"
		if Input.is_action_just_pressed("Down"):
			playerChoiceInput.emit("Down")
			inputResult = "Down"
		if Input.is_action_just_pressed("Interact"):
			inputResult = "Accept"
			playerChoiceInput.emit("Accept")
