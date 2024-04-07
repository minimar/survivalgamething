extends Camera2D

@export var triggerYPos: int
@export var targetCameraPos: Vector2
@export var cameraMoveSpeed: float
const cameraMoveSpeedOffset = .01
var originalPosition
var player
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	originalPosition = position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if player.position.y <= triggerYPos:
		var relativeCameraMoveSpeed = position.distance_to(targetCameraPos)*cameraMoveSpeed*cameraMoveSpeedOffset
		print("Moving Camera?")
		position = position.move_toward(targetCameraPos,relativeCameraMoveSpeed)
	else:
		var relativeCameraMoveSpeed = position.distance_to(originalPosition)*cameraMoveSpeed*cameraMoveSpeedOffset
		position = position.move_toward(originalPosition,relativeCameraMoveSpeed)
