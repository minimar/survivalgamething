extends Interactable

signal elevatorButtonPressed
func onInteract():
	elevatorButtonPressed.emit()
