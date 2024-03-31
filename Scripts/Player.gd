extends CharacterBody2D


const MovementSpeed = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(Input.get_axis("ui_left","ui_right"), Input.get_axis("ui_up","ui_down"))
	velocity = velocity.normalized()*MovementSpeed
	move_and_slide()
	position.x = round(position.x)
	position.y = round(position.y)
	#print(position)
	

