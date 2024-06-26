extends Interactable

@export var elevatorID: String
@export var floor: int
var open = false:
	set(value):
		open = value
		if open:
			$AnimationPlayer.play("doorOpen")
			await $Elevator.animation_finished
			toggleDoorCollision()
		else:
			$AnimationPlayer.play("doorClose")
			await $Elevator.animation_finished
			toggleDoorCollision()


func toggleDoorCollision():
	print('toggle')
	if $ElevatorDoor.collision_layer == 8:
		$ElevatorDoor.collision_layer = 0
		$ElevatorDoor.collision_mask = 0
	else:
		$ElevatorDoor.collision_layer = 8
		$ElevatorDoor.collision_mask = 8

func onInteract():
	open = !open
	SceneSwitcher.elevatorID = elevatorID
	SceneSwitcher.elevatorFloor = floor
