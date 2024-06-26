extends Interactable
class_name DialogueArea
@export var sceneID = ""
@export var dialogueText = ""
@export var dialoguePriority = 1
#Var to change dialogue areas from requiring player interaction, to requiring player hitbox to touch.
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
	#Code for player hitbox detection on dialogueTrigger areas
	if body is Player and isDialogueTrigger:
		get_tree().create_timer(.1)
		body.dialogueSignal.emit(self)
		#If it should only occur once per scene load, this var will be true and will remove collision detection
		if dialogueTriggerOnceOnly:
			collision_layer = 0
			collision_mask = 0
