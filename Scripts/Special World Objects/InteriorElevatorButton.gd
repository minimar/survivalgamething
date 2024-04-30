extends Interactable

signal elevatorButtonPressed
func onInteract():
	print('onInteract called')
	elevatorButtonPressed.emit()
