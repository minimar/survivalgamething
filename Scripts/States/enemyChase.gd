extends State
class_name EnemyChase

var player: Player
@export var enemy: CharacterBody2D

func enter():
	player = get_tree().get_first_node_in_group("Player")

func physicsUpdate(delta:float):
	var playerPosition = player.global_position
	var direction = playerPosition - enemy.position
	#print(direction.length())
	if direction.length() > enemy.aggroRange:
		Transition.emit(self,'EnemySearch')
		return
	if direction.length() > enemy.attackRange:
		enemy.velocity = direction.normalized() * enemy.movementSpeed
	else:
		Transition.emit(self,'EnemyAttack')

func exit():
	enemy.velocity = Vector2()
