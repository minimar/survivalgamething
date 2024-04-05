extends Node
@export var cutsceneObjID:String 
var setup = false
# Called when the node enters the scene tree for the first time.
func _ready():
	print('test9')
	await get_parent().ready
	get_parent().add_to_group("Cutscene Objects")
	get_parent().set_meta("cutsceneObjID",cutsceneObjID)
	setup = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
