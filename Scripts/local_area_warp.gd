extends Node2D
class_name LocalAreaWarp

@export var warp1: Area2D
@export var warp2: Area2D
@export var warp1SubsceneID: String
@export var warp2SubsceneID: String
@export var subsceneHandler: SubsceneHandler

func _ready():
	await get_parent().ready
	var player = get_tree().get_first_node_in_group("Player")
	warp1.body_entered.connect(_on_player_entered.bind(warp1))
	warp2.body_entered.connect(_on_player_entered.bind(warp2))

func _on_player_entered(player,warp):
	print(player.name + warp.name)
	if warp == warp1:
		player.position = warp2.position
		if subsceneHandler:
			subsceneHandler.changeSubScene(warp2SubsceneID, false)
	else:
		player.position = warp1.position
		if subsceneHandler:
			subsceneHandler.changeSubScene(warp1SubsceneID, false)
	print(player.position)
	

