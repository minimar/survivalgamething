extends PanelContainer
@onready var inventorySlots = $MarginContainer/VBoxContainer/Slots/InventorySlots
@onready var outfitSlots = $MarginContainer/VBoxContainer/Slots/Outfit
@onready var interactionAndInfo = $"MarginContainer/VBoxContainer/Interaction and Info"
@onready var interaction = $"MarginContainer/VBoxContainer/Interaction and Info/Interaction/MarginContainer/VBoxContainer"
@onready var info = $"MarginContainer/VBoxContainer/Interaction and Info/Info/MarginContainer/VBoxContainer"

@onready var interactionButton = preload("res://Scenes/Instanced Objects/item_interaction_button.tscn")
@onready var infoLabel = preload("res://Scenes/Instanced Objects/item_info_label.tscn")

#Var that updates when the player's item var updates
var items: Array:
	set(value):
		#print("Setting Items")
		items = value
		#print("Items: " + str(items))
		var itemSlotToFill = 0
		#Sets each itemSlot to an item until there are no more items.
		for itemSlot in get_tree().get_nodes_in_group("Item Slots"):
			if itemSlotToFill >= items.size():
				itemSlot.item = null
			else:
				itemSlot.item = items[itemSlotToFill]
				itemSlotToFill += 1

#Var that updates when the player's outfit var updates
var outfit: Array:
	set(value):
		print("Setting Outfit")
		outfit = value
		#Sets each outfit slot to its specific outfit piece
		for itemSlot in get_tree().get_nodes_in_group("Outfit Slots"):
			match itemSlot.name:
				'outfit0': itemSlot.item = outfit[0]
				'outfit1': itemSlot.item = outfit[1]
				'outfit2': itemSlot.item = outfit[2]
#Var that updates when the player gets a gun
var hasGun: bool:
	set(value):
		hasGun = value
		print('hasGun: ' + str(hasGun))
		#Displays the gun item
		if hasGun:
			for slot in get_tree().get_nodes_in_group("Outfit Slots"):
				if slot.name == 'outfit3':
					#print('outfit3 has gun item')
					#print(gunItem.itemName)
					slot.item = gunItem

var gunItem: Item
#Var that updates when the player's bullets update
var bullets: Item:
	set(value):
		bullets = value
		for slot in get_tree().get_nodes_in_group("Outfit Slots"):
			if slot.name == 'outfit4':
				slot.item = bullets
		


var player
# Called when the node enters the scene tree for the first time.
func _ready():
	#Setup
	gunItem = ItemGenerator.makeItem('gun')
	#print("Gun: "+str(gunItem))
	player = get_tree().get_first_node_in_group("Player")
	combining = false
	var itemSlot = preload("res://Scenes/Instanced Objects/item_slot.tscn")
	#Creates itemSlot nodes procedurally
	for i in 30:
		var itemSlotNode := itemSlot.instantiate()
		itemSlotNode.name = 'inv'+str(i)
		itemSlotNode.pressed.connect(_on_slot_pressed.bind(itemSlotNode))
		itemSlotNode.mouse_entered.connect(_on_slot_hovered.bind(itemSlotNode))
		itemSlotNode.mouse_exited.connect(_on_slot_unhovered)
		itemSlotNode.add_to_group("Item Slots")
		inventorySlots.add_child(itemSlotNode)
	#Creates itemSlot nodes for outfit slots procedurally
	for i in 5:
		var itemSlotNode := itemSlot.instantiate()
		itemSlotNode.name = 'outfit'+str(i)
		itemSlotNode.pressed.connect(_on_slot_pressed.bind(itemSlotNode))
		itemSlotNode.mouse_entered.connect(_on_slot_hovered.bind(itemSlotNode))
		itemSlotNode.mouse_exited.connect(_on_slot_unhovered)
		itemSlotNode.add_to_group("Outfit Slots")
		outfitSlots.add_child(itemSlotNode)

#When slot button is pressed
func _on_slot_pressed(slotNode: Node) -> void:
	if combining:
		combine(selectedSlot.item,slotNode.item)
		return
	if selectedSlot:
		selectedSlot.selected = false
	selectedSlot = slotNode
	slotNode.selected = true

#When slot button is hovered
func _on_slot_hovered(slotNode: Node) -> void:
	if not combining and slotNode.item:
		hoveredSlot = slotNode

#When slot button is unhovered
func _on_slot_unhovered() -> void:
	hoveredSlot = null

#Updates interactions and info when a new slot is selected or hovered
var selectedSlot:
	set(value):
		selectedSlot = value
		updateInteractionAndInfo()
var hoveredSlot:
	set(value):
		hoveredSlot = value
		updateInteractionAndInfo()

#When an interaction button is pressed, I.e. Use, Combine, Discard
func _on_interaction_button_pressed(buttonNode:Node,item: Item)-> void:
	print('Button Name: ' + buttonNode.name)
	match buttonNode.name:
		'Use': 
			if item is Food:
				player.eat(item)
			if item is Clothing:
				player.equip(item)
		'Combine': 
			print('Combine')
			combining = !combining
		'Discard':
			item.quantity -= 1
			player.items[player.items.find(item)] = item
			player.updateItems()
	updateInteractionAndInfo()

#Combining mode flag, sets text to display "Combine With:"
var combining: bool:
	set(value):
		combining = value
		if combining:
			$MarginContainer/VBoxContainer/Label.text = "Combine With:"
		else:
			$MarginContainer/VBoxContainer/Label.text = ""

#Dictionary of all item combinations
#Consider moving this to item generator?
const combinationDict := {
	'rock-wood': 'test',
	'rock-bullet': 'test'
}


#Function to attempt to combine two items using combinationDict
func combine(item1:Item,item2:Item) -> void:
	var newItemID
	if item1.quantity < 1 or item2.quantity < 1:
		return
	#print(item1.itemID+'-'+item2.itemID)
	
	#Checks if the combinationDict has a resulting item from combining the two items
	if combinationDict.has(item1.itemID+'-'+item2.itemID):
		newItemID = combinationDict[item1.itemID+'-'+item2.itemID]
	elif combinationDict.has(item2.itemID+'-'+item1.itemID):
		newItemID = combinationDict[item2.itemID+'-'+item1.itemID]
	#print("New Item Name: "+ str(newItemID))
	
	#If there is no resulting item, returns early
	if !newItemID:
		return
	
	#Different handling cases based on whether the item can replace an item in its slot, or must go into a new slot to prevent going above max slot count.
	if item1.quantity == 1 and item1.itemID != 'bullet':
		player.items[player.items.find(item1)] = ItemGenerator.makeItem(newItemID)
		if item2.itemID != 'bullet':
			player.items[player.items.find(item2)].quantity -= 1
		else:
			player.bullets.quantity -= 1
		player.updateItems()
		combining = false
		return
	if item2.quantity == 1 and item2.itemID != 'bullet':
		player.items[player.items.find(item2)] = ItemGenerator.makeItem(newItemID)
		if item1.itemID != 'bullet':
			player.items[player.items.find(item1)].quantity -= 1
		else:
			player.bullets.quantity -= 1
		player.updateItems()
		combining = false
		return
	if player.items.size() == 30:
		return
	player.items.append(ItemGenerator.makeItem(newItemID))
	if item1.itemID != 'bullet':
		player.items[player.items.find(item1)].quantity -= 1
	else:
		player.bullets.quantity -= 1
	if item2.itemID != 'bullet':
		player.items[player.items.find(item2)].quantity -= 1
	else:
		player.bullets.quantity -= 1
	for item in items:
		#print(item.itemName)
		pass
	player.updateItems()
	combining = false




#Updates the interaction buttons and info displayed for the currently selected or hovered slot.
func updateInteractionAndInfo():
	var itemSlot
	
	for node in interaction.get_children():
		node.name = 'blablabla'
		node.queue_free()
	for node in info.get_children():
		node.name = 'blablabla'
		node.queue_free()
	if hoveredSlot:
		print("Hovered Slot")
		itemSlot = hoveredSlot
	else:
		print("Selected Slot")
		itemSlot = selectedSlot
	if !itemSlot or !itemSlot.item:
		return
	
	var item = itemSlot.item
	#Interaction Buttons
	if item.get('usable') and 'inv' in itemSlot.name:
		print('Is Usable')
		var interactionButtonNode = interactionButton.instantiate()
		interactionButtonNode.name = 'Use'
		if item is Food:
			interactionButtonNode.find_child("Label").text = 'Eat'
		elif item is Clothing:
			interactionButtonNode.find_child("Label").text = 'Equip'
		else:
			interactionButtonNode.find_child("Label").text = 'Use'
		interaction.add_child(interactionButtonNode)
		interactionButtonNode.pressed.connect(_on_interaction_button_pressed.bind(interactionButtonNode,item))
	if 'inv' in itemSlot.name or item.itemID == 'bullet':
		var interactionButtonNode = interactionButton.instantiate()
		interactionButtonNode.name = 'Combine'
		print('Button Created: '+interactionButtonNode.name)
		interactionButtonNode.find_child("Label").text = 'Combine'
		interaction.add_child(interactionButtonNode)
		interactionButtonNode.pressed.connect(_on_interaction_button_pressed.bind(interactionButtonNode,item))
	if (!item.get('keyItem')) and 'inv' in itemSlot.name:
		print("Item is not key item")
		var interactionButtonNode = interactionButton.instantiate()
		interactionButtonNode.name = 'Discard'
		print('Button Created: '+interactionButtonNode.name)
		interactionButtonNode.find_child("Label").text = 'Discard'
		interaction.add_child(interactionButtonNode)
		interactionButtonNode.pressed.connect(_on_interaction_button_pressed.bind(interactionButtonNode,item))
	#Info Labels
	var infoLabelNode = infoLabel.instantiate()
	infoLabelNode.text = item.itemName
	infoLabelNode.set_label_settings(LabelSettings.new())
	infoLabelNode.label_settings.font_size = 32
	info.add_child(infoLabelNode)
	infoLabelNode = infoLabel.instantiate()
	infoLabelNode.text = item.description
	info.add_child(infoLabelNode)
