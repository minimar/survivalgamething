extends VBoxContainer

@onready var statBubble = preload("res://Scenes/Instanced Objects/stat_bar.tscn")
@onready var healthBar = $HealthBar
@onready var hungerBar = $HungerBar


var player
var health: int:
	set(value):
		if health == value:
			return
		health = value
		updateStatBar('health')
var hunger: int:
	set(value):
		if hunger == value:
			return
		hunger = value
		updateStatBar('hunger')



func updateStatBar(statType):
	var stat
	if statType == 'health':
		stat = health
		for bubble in healthBar.get_children():
			healthBar.remove_child(bubble)
			bubble.queue_free()
	elif statType == 'hunger':
		stat = hunger
		for bubble in hungerBar.get_children():
			hungerBar.remove_child(bubble)
			bubble.queue_free()
	var roundedStat = float(snapped(stat,5))
	var numberOfBars = ceil(roundedStat/10)
	
	
	
	for i in numberOfBars:
		var statBubbleNode = statBubble.instantiate()
		statBubbleNode.type = statType
		if statType == 'health':
			healthBar.add_child(statBubbleNode)
		elif statType == 'hunger':
			hungerBar.add_child(statBubbleNode)
		if i == numberOfBars and roundedStat % 10 == 5:
			statBubbleNode.halved = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !player:
		player = get_tree().get_first_node_in_group("Player")
	if health != player.health:
		health = player.health
	if hunger != player.hunger:
		hunger = player.hunger
	
