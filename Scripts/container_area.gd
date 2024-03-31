extends Area2D
class_name ContainerNode
@export var containerItems = {}
@export var isItemLoose = false
@export var containerOpened = false:
	set(value):
		if value:
			collision_layer = 0
			collision_mask = 0
			if isItemLoose:
				get_parent().queue_free()
		containerOpened = value


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Containers")


