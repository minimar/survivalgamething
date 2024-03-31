extends PanelContainer

var items: Array:
	set(value):
		print("Setting Items")
		items = value
		var itemSlotToFill = 0
		for itemSlot in get_tree().get_nodes_in_group("Item Slots"):
			if itemSlotToFill >= items.size():
				break
			else:
				itemSlot.item = items[itemSlotToFill]
				itemSlotToFill += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var itemSlot = preload("res://Scenes/Instanced Objects/item_slot.tscn")
	for i in 30:
		var itemSlotNode = itemSlot.instantiate()
		itemSlotNode.name = 'inv'+str(i)
		itemSlotNode.pressed.connect(_on_slot_pressed.bind(itemSlotNode.name))
		itemSlotNode.add_to_group("Item Slots")
		$MarginContainer/HBoxContainer/InventorySlots.add_child(itemSlotNode)
	for i in 4:
		var itemSlotNode = itemSlot.instantiate()
		itemSlotNode.name = 'outfit'+str(i)
		itemSlotNode.pressed.connect(_on_slot_pressed.bind(itemSlotNode.name))
		$MarginContainer/HBoxContainer/Outfit.add_child(itemSlotNode)

func _on_slot_pressed(slotName):
	print(slotName)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
