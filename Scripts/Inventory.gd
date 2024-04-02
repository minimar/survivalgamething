extends PanelContainer
@onready var inventorySlots = $MarginContainer/VBoxContainer/Slots/InventorySlots
@onready var outfitSlots = $MarginContainer/VBoxContainer/Slots/Outfit
@onready var interactionAndInfo = $"MarginContainer/VBoxContainer/Interaction and Info"
@onready var interaction = $"MarginContainer/VBoxContainer/Interaction and Info/Interaction"
@onready var info = $"MarginContainer/VBoxContainer/Interaction and Info/Info"

@onready var interactionButton


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
		var itemSlotNode := itemSlot.instantiate()
		itemSlotNode.name = 'inv'+str(i)
		itemSlotNode.pressed.connect(_on_slot_pressed.bind(itemSlotNode))
		itemSlotNode.mouse_entered.connect(_on_slot_hovered.bind(itemSlotNode))
		itemSlotNode.mouse_exited.connect(_on_slot_unhovered)
		itemSlotNode.add_to_group("Item Slots")
		inventorySlots.add_child(itemSlotNode)
	for i in 5:
		var itemSlotNode := itemSlot.instantiate()
		itemSlotNode.name = 'outfit'+str(i)
		itemSlotNode.pressed.connect(_on_slot_pressed.bind(itemSlotNode))
		itemSlotNode.mouse_entered.connect(_on_slot_hovered.bind(itemSlotNode))
		itemSlotNode.mouse_exited.connect(_on_slot_unhovered)
		itemSlotNode.add_to_group("Outfit Slots")
		outfitSlots.add_child(itemSlotNode)

func _on_slot_pressed(slotNode):
	selectedSlot = slotNode


func _on_slot_hovered(slotNode):
	if not combining:
		hoveredSlot = slotNode

func _on_slot_unhovered(slotNode):
	hoveredSlot = null

var combining
var selectedSlot:
	set(value):
		selectedSlot = value
		updateInteractionAndInfo()
var hoveredSlot:
	set(value):
		hoveredSlot = value
		updateInteractionAndInfo()

func updateInteractionAndInfo():
	var itemSlot
	if hoveredSlot:
		itemSlot = hoveredSlot
	else:
		itemSlot = selectedSlot
	if !itemSlot:
		return
	for node in interaction.get_children():
		node.queue_free()
	for node in info.get_children():
		node.queue_free()
	if !itemSlot.item:
		return
	var item = itemSlot.item
	if item.get('usable'):
		pass
