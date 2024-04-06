extends Node
@export var cutsceneObjID:String 

# Called when the node enters the scene tree for the first time.
func _ready():
	#Awaits parent ready
	await get_parent().ready
	#Adds parent to cutscene objects
	get_parent().add_to_group("Cutscene Objects")
	#Gives the parent objID metadata
	get_parent().set_meta("cutsceneObjID",cutsceneObjID)
	

