extends CharacterBody2D
class_name Player

const defaultMovementSpeed = 100
const aimSpeedDebuff = .3
const hitboxOffset = .18
const reticleOffset = 80
const maxInvSlots = 30
const gunRange = 700
const gunDamage = 10
#The distance at which enemies can spawn on a new day
const minimumSpawnDistance = 300

signal dialogueSignal
signal showGenericText
signal updateInv
signal playerDeath

var health = 100: 
	set(value):
		health = value
		if health > 100:
			health = 100
		print("Player Health: "+str(health))
		if health < 1:
			playerDeath.emit()
var hunger = 50:
	set(value):
		hunger = value
		if hunger > 100:
			hunger = 100
		if hunger < 0:
			hunger = 0
		print("Player Hunger: "+str(hunger))
var items = []



func updateItems():
	var newItems = []
	for item in items:
		for addedItem in newItems:
			#print(addedItem)
			if item.itemName == addedItem.itemName and addedItem.stackable:
				if addedItem.quantity + item.quantity > addedItem.maxStack:
					item.quantity = item.quantity - (addedItem.maxStack - addedItem.quantity)
					addedItem.quantity = addedItem.maxStack
				else:
					addedItem.quantity += item.quantity
					item.quantity = 0
			if item.quantity == 0:
				break
		if item.quantity > 0:
			newItems.append(item)
	items = newItems
	#print('Player Items: ' + str(items))
	updateInv.emit([items,outfit,hasGun,bullets])


var bulletsInGun = 6
var bullets: Item
var outfit = []
func sortOutfit():
	var oldOutfit = outfit
	var head
	var torso
	var legs
	for outfitPiece in oldOutfit:
		match outfitPiece.type:
			'head': head = outfitPiece
			'torso': torso = outfitPiece
			'legs': legs = outfitPiece
	outfit = [head,torso,legs]

func equip(item):
	var itemIndex = items.find(item)
	var oldOutfitItem
	match item.type:
		'head': 
			oldOutfitItem = outfit[0]
			outfit[0] = item
			items[itemIndex] = oldOutfitItem
		'torso':
			oldOutfitItem = outfit[1]
			outfit[1] = item
			items[itemIndex] = oldOutfitItem
		'legs':
			oldOutfitItem = outfit[2]
			outfit[2] = item
			items[itemIndex] = oldOutfitItem
	updateItems()
var hasGun = true

var movementSpeed = defaultMovementSpeed

#Pause for scene
var scenePause
#Pause for overall game
var gamePause = false
func toggleGamePause():
	gamePause = !gamePause

@onready var interactionArea: Area2D= $InteractionArea
@onready var settings = $"/root/Settings"

# Called when the node enters the scene tree for the first time.
func _ready():
	if outfit == []:
		outfit = [ItemGenerator.makeItem('basicHead'),ItemGenerator.makeItem('basicTorso'),ItemGenerator.makeItem('basicLegs')]
	for piece in outfit:
		print(piece.itemName)
	updateItems()
	add_to_group("Player")
	add_to_group("Pausing Nodes")


func eat(foodItem = 'quick'):
	if foodItem is String:
		if hunger >= 95:
			return "Too full"
		var foodItems = []
		for item in items:
			if item is Food:
				foodItems.append(item)
		if foodItems == []:
			return "No food."
		for food in foodItems:
			if food.type == 'cooked' and food.foodSaturation + hunger <= 100:
				food.quantity -= 1
				hunger += food.foodSaturation
				updateItems()
				return "Ate "+food.itemName
		for food in foodItems:
			if food.type == 'basic' and food.foodSaturation + hunger <= 100:
				food.quantity -= 1
				hunger += food.foodSaturation
				updateItems()
				return "Ate "+food.itemName
		for food in foodItems:
			if food.type == 'raw' and food.foodSaturation + hunger <= 100:
				food.quantity -= 1
				hunger += food.foodSaturation
				updateItems()
				return "Ate "+food.itemName
		return "Too full."
	
	for item in items:
		if item == foodItem:
			item.quantity -= 1
			hunger += item.foodSaturation
			updateItems()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if scenePause or gamePause:
		return
	velocity = Vector2(Input.get_axis("Left","Right"), Input.get_axis("Up","Down"))
	velocity = velocity.normalized()*movementSpeed
	move_and_slide()
	if velocity != Vector2(0,0):
		interactionArea.position = Vector2(0,-4)
		interactionArea.position += velocity * hitboxOffset

signal advanceScene
var fastReload = false
var normalReload = false
var reloadTimer = 0.0
var debugHealthTimer = 0.0
const hungerDamageCooldown = 15.0
var hungerDamageTimer = 0.0
func _process(delta):
	if gamePause:
		return
	#debugHealthTimer += delta
	#if debugHealthTimer > 1.0:
	#	debugHealthTimer = 0.0
	#	health -= 5
	#	hunger -= 3
	hungerDamageTimer += delta
	if hungerDamageTimer > hungerDamageCooldown:
		health -= 5
		hungerDamageTimer = 0.0
	reloadTimer += delta
	if fastReload and reloadTimer > 2.0:
		if bullets and bullets.quantity > 0:
			bulletsInGun = min(bullets.quantity,6)
			bullets.quantity -= bulletsInGun
			updateItems()
		fastReload = false
	if normalReload and reloadTimer > 1.0:
		if (bulletsInGun < 6) and bullets and bullets.quantity > 0:
			bulletsInGun += 1
			bullets.quantity -= 1
			updateItems()
			reloadTimer = 0
		else:
			normalReload = false
	
	if Input.is_action_just_pressed("Reload"):
		reload()
	
	if Input.is_action_just_pressed("Quick Eat"):
		print(eat())
	
	#Debug give player bullets item
	if Input.is_action_just_pressed('Inventory'):
		var bulletItem = ItemGenerator.makeItem('bullet')
		bulletItem.quantity = 99
		bullets = bulletItem
		updateItems()
		#print(bullets.itemName + str(bullets.quantity))
	
	
	if Input.is_action_just_pressed("Interact"):
		if !scenePause:
			if !checkContainers():
				if !checkDialogueNodes():
					for node in interactionArea.get_overlapping_areas():
						node.onInteract()
		else:
			print("player emitted signal")
			advanceScene.emit()
	if settings.controlMode == 'kb&m':
		if Input.is_action_pressed("Aim"):
			$"Aiming Reticle".visible = true
			movementSpeed = defaultMovementSpeed*aimSpeedDebuff
		else:
			$"Aiming Reticle".visible = false
			movementSpeed = defaultMovementSpeed
		$"Aiming Reticle".global_position = get_global_mouse_position()
		updateGunRay()
		if Input.is_action_just_pressed("FireGun"):
			fireGun()
	else:
		var controllerAimVector = Vector2(Input.get_axis('AimLeft','AimRight'),Input.get_axis('AimUp','AimDown')).normalized()
		if controllerAimVector != Vector2(0,0):
			$"Aiming Reticle".visible = true
			movementSpeed = defaultMovementSpeed*aimSpeedDebuff
		else:
			$"Aiming Reticle".visible = false
			movementSpeed = defaultMovementSpeed
		$"Aiming Reticle".position = Vector2(0,0)
		$"Aiming Reticle".position += controllerAimVector*reticleOffset
		updateGunRay()
		if has_node("Camera2D"):
			$Camera2D.position = $Camera2D.position.move_toward((controllerAimVector*reticleOffset)/3,5)
		if Input.is_action_just_pressed("FireGun"):
			fireGun()
	

func updateGunRay():
	var playerPosition = global_position
	var reticlePosition = $"Aiming Reticle".global_position
	$GunRay.target_position = (reticlePosition-playerPosition).normalized()*gunRange
	#ENABLE THIS TO VISUALIZE GUN RAYCAST
	$GunRay/GunRayDebug.points[1] = $GunRay.target_position

func fireGun():
	reload('cancel')
	if $"Aiming Reticle".visible and bulletsInGun > 0 and hasGun:
		bulletsInGun -= 1
		#print("BANG: "+str(bulletsInGun))
		if $GunRay.is_colliding():
		#	print('is colliding' + $GunRay.get_collider().name)
			if $GunRay.get_collider().get('health'):
				$GunRay.get_collider().health -= gunDamage
		#		print('dealt damage')
		

func reload(doCancel = 'false'):
	if hasGun and doCancel == 'false':
		var hasSpeedLoader = false
		for item in items:
			if item.itemName == 'Speed Loader':
				hasSpeedLoader = true
				break
		if hasSpeedLoader:
			reloadTimer = 0
			fastReload = true
			return
		else:
			reloadTimer = 0
			normalReload = true
			return
	fastReload = false
	normalReload = false

func checkContainers() -> bool:
	var containerNodes = interactionArea.get_overlapping_areas()
	var container: ContainerNode
	for node in containerNodes:
		if node is ContainerNode:
			container = node
			break
	if not container:
		return false
	container.onInteract()
	var backupItems = items
	var itemTextList = ""
	#print(container)
	for itemKey in container.containerItems:
		var itemQuantity = 1
		if container.containerItems[itemKey]:
			itemQuantity = container.containerItems[itemKey]
		var item = ItemGenerator.makeItem(itemKey)
		item.quantity = itemQuantity
		itemTextList += item.itemName +" ("+str(item.quantity)+")\n"
		for checkItem in items:
			#print(checkItem)
			if item.itemName == checkItem.itemName and checkItem.stackable:
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
	var text
	if items.size() > maxInvSlots:
		items = backupItems
		text = "You do not have enough room for these items:\n"
		text += itemTextList
		showGenericText.emit(text)
		return true
	text = "You find:\n"
	text += itemTextList
	showGenericText.emit(text)
	container.containerOpened = true
	updateInv.emit([items,outfit,hasGun,bullets])
	return true
	



func checkDialogueNodes():
	var dialogueNodes = interactionArea.get_overlapping_areas()
	if dialogueNodes.size() == 0:
		showGenericText.emit("")
		return false
	var priorityDialogueNode: DialogueArea
	for dialogueNode in dialogueNodes:
		if not priorityDialogueNode and dialogueNode is DialogueArea:
			priorityDialogueNode = dialogueNode
		elif dialogueNode is DialogueArea and dialogueNode.dialoguePriority > priorityDialogueNode.dialoguePriority:
			priorityDialogueNode = dialogueNode
	if priorityDialogueNode:
		priorityDialogueNode.onInteract()
		dialogueSignal.emit(priorityDialogueNode)
		return true
	return false
