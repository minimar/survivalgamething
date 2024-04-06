extends State
class_name EnemyIdle

@export var enemy: CharacterBody2D
@export var sightCone: Area2D
@export var idleMoveRatio:= .5
var sprite: AnimatedSprite2D 
var animationPlayer: AnimationPlayer 
var moveDirection: Vector2
var timer: float


func randomizeValues():
	randomize()
	timer = randf_range(enemy.averageWanderTimer*.5,enemy.averageWanderTimer*2)
	var randomValue = randi_range(1,3)
	if randomValue == 1:
		moveDirection = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
	else:
		moveDirection = Vector2()

func enter():
	sprite = enemy.find_child("Sprite") 
	animationPlayer = sprite.find_child("AnimationPlayer")
	randomizeValues()

func exit():
	pass

func physicsUpdate(delta:float):
	#print('physics updated')
	if enemy:
		enemy.velocity = moveDirection * enemy.movementSpeed * idleMoveRatio
	
func update(delta:float):
	timer -= delta
	if timer <= 0.0:
		randomizeValues()
	
	if sightCone.get_overlapping_bodies():
		Transition.emit(self,'EnemyChase')
