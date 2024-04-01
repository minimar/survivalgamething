extends Area2D
class_name ContainerNode
@export var containerID: String
@export var containerItems = {}
@export var isItemLoose = false
@export var containerOpened = false:
	set(value):
		if value:
			collision_layer = 0
			collision_mask = 0
			if isItemLoose:
				get_parent().visible = false
		containerOpened = value


# Called when the node enters the scene tree for the first time.
func _ready():
	name = containerID
	print("Adding " + containerID + 'To Containers Group')
	add_to_group("Containers")
	print("Containers: "+str(get_tree().get_nodes_in_group("Containers")))

