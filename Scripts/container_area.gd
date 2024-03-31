extends Area2D
class_name ContainerNode
@export var containerItems = []
@export var containerOpened = false:
	set(value):
		self.visible = !value
		containerOpened = value


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Containers")


