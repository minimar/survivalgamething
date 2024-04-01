extends State
class_name EnemyIdle

@export var enemy: CharacterBody2D
@export var sightCone: Area2D
@export var idleMoveRatio:= .5

var moveDirection: Vector2
var timer: float

func randomizeValues():
	randomize()
	moveDirection = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
	timer = randf_range(enemy.averageWanderTimer*.5,enemy.averageWanderTimer*2)

func enter():
	randomizeValues()

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
