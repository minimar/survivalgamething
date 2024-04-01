extends State
class_name EnemySearch

var player: Player
@export var enemy: CharacterBody2D

var searchPosition: Vector2

func enter():
	player = get_tree().get_first_node_in_group("Player")
	searchPosition = player.global_position

func physicsUpdate(delta:float):
	var direction =  searchPosition - enemy.global_position
	if direction.length() < 5:
		Transition.emit(self,'EnemyIdle')
	else:
		enemy.velocity = direction.normalized() * enemy.moveSpeed
