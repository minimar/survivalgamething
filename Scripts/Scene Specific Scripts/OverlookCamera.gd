extends Camera2D

@export var triggerYPos: int
@export var targetCameraPos: Vector2
@export var cameraMoveSpeed: float
const cameraMoveSpeedOffset = .01
var originalPosition
var player
func _ready():
	await get_parent().ready
	player = get_tree().get_first_node_in_group("Player")
	originalPosition = get_parent().position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var holderPosition = get_parent().position
	if player.position.y <= triggerYPos:
		var relativeCameraMoveSpeed = holderPosition.distance_to(targetCameraPos)*cameraMoveSpeed*cameraMoveSpeedOffset
		#print("Moving Camera?")
		get_parent().position = holderPosition.move_toward(targetCameraPos,relativeCameraMoveSpeed)
	else:
		var relativeCameraMoveSpeed = holderPosition.distance_to(originalPosition)*cameraMoveSpeed*cameraMoveSpeedOffset
		get_parent().position = holderPosition.move_toward(originalPosition,relativeCameraMoveSpeed)
