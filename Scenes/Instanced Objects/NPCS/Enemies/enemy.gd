extends CharacterBody2D
class_name Enemy

@export var health := 30:
	set(value):
		health = value
		if health <= 0:
			queue_free()

@export var movementSpeed:= 20.0
@export var averageWanderTimer:= 1.0
@export var aggroRange:= 150.0
@export var attackRange:= 30.0
@export var rotationSpeed:= 12.0
@export var hurtboxOffset := 15.0
@export var damage := 10
@export var attackCooldown:= 2.0



func _physics_process(delta):
	$SightCone.rotation = move_toward($SightCone.rotation,velocity.angle(),deg_to_rad(rotationSpeed))
	move_and_slide()


