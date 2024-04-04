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
@export var dialogueTriggerOnceOnly := false
#var initialCheck = true
#func _process(_delta):
	#if initialCheck and has_overlapping_bodies():
		#get_overlapping_bodies()[0].dialogueSignal.emit(self)
		#initialCheck = false

func _on_body_entered(body):
	if body is Player and isDialogueTrigger:
		body.dialogueSignal.emit(self)
		if dialogueTriggerOnceOnly:
			collision_layer = 0
			collision_mask = 0
