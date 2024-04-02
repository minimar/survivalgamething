extends Area2D
class_name dialogueArea
@export var sceneID = ""
@export var dialogueText = ""
@export var dialoguePriority = 1
@export var isDialogueTrigger := false:
	set(value):
		isDialogueTrigger = value
		if isDialogueTrigger:
			collision_layer = 8
			collision_mask = 8
		else:
			collision_layer = 2
			collision_mask = 2


func _on_body_entered(body):
	if body is Player and isDialogueTrigger:
		body.dialogueSignal.emit(self)
