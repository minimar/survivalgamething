extends Node

var target_fps = 60
var controlMode = 'kb&m'
const controlModes = ['kb&m','controller']

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.set_max_fps(target_fps)

