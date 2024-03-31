extends CharacterBody2D
class_name Player

const MovementSpeed = 100
const dialogueOffset = .18
const maxInvSlots = 30

signal dialogueSignal
signal showGenericText
signal updateInv

var health = 100
var hunger = 100
var items = []:
	set(value):
		print('player items set')
		items = value
		print("Help: " + str(updateInv.get_connections()))
		updateInv.emit(items)
var bulletsInGun = 6
var outfit = []

#Pause for scene
var scenePause


@onready var dialogueArea = $DialogueArea
@onready var containersArea = $ContainersArea
@onready var itemGenerator = $"/root/ItemGenerator"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !scenePause:
		velocity = Vector2(Input.get_axis("ui_left","ui_right"), Input.get_axis("ui_up","ui_down"))
		velocity = velocity.normalized()*MovementSpeed
		move_and_slide()
		if velocity != Vector2(0,0):
			dialogueArea.position = Vector2(0,12)
			dialogueArea.position += velocity * dialogueOffset

signal advanceScene
func _process(delta):
	if Input.is_action_just_pressed("Interact"):
		if !scenePause:
			if !checkContainers():
				#print("test")
				checkDialogueNodes()
		else:
			advanceScene.emit()

func checkContainers() -> bool:
	var containerNodes = containersArea.get_overlapping_areas()
	if containerNodes.size() == 0:
		return false
	var container = containerNodes[0]
	var backupItems = items
	var itemTextList = ""
	print(container)
	for itemKey in container.containerItems:
		var itemQuantity = 1
		if container.containerItems[itemKey]:
			itemQuantity = container.containerItems[itemKey]
		var item = itemGenerator.makeItem(itemKey)
		item.quantity = itemQuantity
		itemTextList += item.itemName +" ("+str(item.quantity)+")\n"
		for checkItem in items:
			if item.itemName == checkItem.itemName:
				if checkItem.quantity + item.quantity > checkItem.maxStack:
					item.quantity = item.quantity - (checkItem.maxStack - checkItem.quantity)
					checkItem.quantity = checkItem.maxStack
				else:
					checkItem.quantity += item.quantity
					item.quantity = 0
			if item.quantity == 0:
				break
		if item.quantity != 0:
			items.append(item)
	if items.size() > maxInvSlots:
		items = backupItems
		var text = "You do not have enough room for these items:\n"
		text += itemTextList
		showGenericText.emit(text)
		return true
	var text = "You find:\n"
	text += itemTextList
	showGenericText.emit(text)
	container.containerOpened = true
	items = items
	return true

func checkDialogueNodes():
	var dialogueNodes = dialogueArea.get_overlapping_areas()
	if dialogueNodes.size() == 0:
		showGenericText.emit("")
		return
	var priorityDialogueNode = dialogueNodes[0]
	for dialogueNode in dialogueNodes:
		if dialogueNode.dialoguePriority > priorityDialogueNode.dialoguePriority:
			priorityDialogueNode = dialogueNode
	dialogueSignal.emit(priorityDialogueNode)
