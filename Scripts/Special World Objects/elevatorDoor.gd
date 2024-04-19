extends Interactable

var open = false:
	set(value):
		open = value
		if open:
			$AnimationPlayer.play("doorOpen")
		else:
			$AnimationPlayer.play("doorClose")


func toggleDoorCollision():
	if $ElevatorDoor.collision_layer == 8:
		$ElevatorDoor.collision_layer = 0
		$ElevatorDoor.collision_mask = 0
	else:
		$ElevatorDoor.collision_layer = 8
		$ElevatorDoor.collision_mask = 8

func onInteract():
	open = !open
