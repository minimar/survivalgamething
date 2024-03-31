extends Node

var target_fps = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.set_max_fps(target_fps)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
