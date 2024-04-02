extends Node
@export var cutsceneObjID:String 
var setup = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !setup:
		get_parent().add_to_group("Cutscene Objects")
		get_parent().set_meta("cutsceneObjID",cutsceneObjID)
		setup = true
