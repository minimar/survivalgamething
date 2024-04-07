extends CharacterBody2D
class_name Enemy

@export var enemyID: String

@export var health := 30:
	set(value):
		health = value
		if health <= 0:
			queue_free()
@export var enemyName := "enemy"
@export var movementSpeed:= 20.0
@export var averageWanderTimer:= 1.0
@export var aggroRange:= 150.0
@export var attackRange:= 30.0
@export var rotationSpeed:= 12.0
@export var hurtboxOffset := 15.0
@export var damage := 10
@export var attackCooldown:= 2.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animationPlayer: AnimationPlayer = $"Sprite/AnimationPlayer"

func _ready():
	add_to_group("Enemies")

#Rotates the sightCone based on the current velocity direction, then runs updateMovementAnim
func _physics_process(_delta):
	$SightCone.rotation = move_toward($SightCone.rotation,velocity.angle(),deg_to_rad(rotationSpeed))
	if 'walk' in animationPlayer.current_animation or velocity != Vector2():
		if velocity == Vector2():
			if animationPlayer.current_animation == 'walkLeft':
				sprite.flip_h = true
			animationPlayer.play('idle')
		else:
			updateMovementAnim()
	move_and_slide()

#Updates the movement animation to match movement velocity
func updateMovementAnim():
	sprite.flip_h = false
	var moveDirection = velocity
	var animationDirection = 'walkDown'
	if moveDirection.y < 0:
		animationDirection = 'walkUp'
	if abs(moveDirection.x) > abs(moveDirection.y):
		animationDirection = 'walkRight'
		if moveDirection.x < 0:
			animationDirection = 'walkLeft'
	animationPlayer.play(animationDirection)
