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

var outfit: Array
var hasGun: bool
var bullets: Item:
	set(value):
		bullets = value
		for slot in get_tree().get_nodes_in_group("Outfit Slots"):
			if slot.name == 'outfit4':
				slot.item = bullets
		



# Called when the node enters the scene tree for the first time.
func _ready():
	var itemSlot = preload("res://Scenes/Instanced Objects/item_slot.tscn")
	for i in 30:
		var itemSlotNode = itemSlot.instantiate()
		itemSlotNode.name = 'inv'+str(i)
		itemSlotNode.pressed.connect(_on_slot_pressed.bind(itemSlotNode.name))
		itemSlotNode.add_to_group("Item Slots")
		$MarginContainer/HBoxContainer/InventorySlots.add_child(itemSlotNode)
	for i in 5:
		var itemSlotNode = itemSlot.instantiate()
		itemSlotNode.name = 'outfit'+str(i)
		itemSlotNode.pressed.connect(_on_slot_pressed.bind(itemSlotNode.name))
		itemSlotNode.add_to_group("Outfit Slots")
		$MarginContainer/HBoxContainer/Outfit.add_child(itemSlotNode)

func _on_slot_pressed(slotName):
	print(slotName)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
