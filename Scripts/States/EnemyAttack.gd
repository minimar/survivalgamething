extends State
class_name EnemyAttack

@export var enemy: CharacterBody2D
@export var hurtbox: Area2D

var player: Player
var cooldownTimer = 0

func enter():
	player = get_tree().get_first_node_in_group("Player")
	hurtbox.position = (player.global_position - enemy.position).normalized()*enemy.hurtboxOffset
	attack()
	
	
	
	
func attack():
	if hurtbox.has_overlapping_bodies():
		player.health -= enemy.damage
	cooldownTimer = enemy.attackCooldown

func exit():
	hurtbox.position = Vector2(0,0)

func physicsUpdate(delta:float):
	cooldownTimer -= delta
	if cooldownTimer <= 0.0:
		if hurtbox.has_overlapping_bodies():
			attack()
		else:
			Transition.emit(self,'EnemyChase')
		
