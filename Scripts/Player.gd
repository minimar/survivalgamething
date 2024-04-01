extends CharacterBody2D
class_name Player

const defaultMovementSpeed = 100
const aimSpeedDebuff = .3
const hitboxOffset = .18
const reticleOffset = 80
const maxInvSlots = 30
const gunRange = 700
const gunDamage = 10

signal dialogueSignal
signal showGenericText
signal updateInv

var health = 100: 
	set(value):
		health = value
		print("Player Health: "+str(health))
		if health < 1:
			print("game over")
var hunger = 100
var items = []:
	set(value):
		print('player items set')
		items = value
		print("Help: " + str(updateInv.get_connections()))
		
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

var hasGun = true

var movementSpeed = defaultMovementSpeed

#Pause for scene
var scenePause


@onready var dialogueArea = $DialogueArea
@onready var containersArea = $ContainersArea
var itemGenerator 
@onready var settings = $"/root/Settings"

# Called when the node enters the scene tree for the first time.
func _ready():
	itemGenerator = $"/root/ItemGenerator"
	if outfit == []:
		outfit = [itemGenerator.makeItem('basicHead'),itemGenerator.makeItem('basicTorso'),itemGenerator.makeItem('basicLegs')]
	add_to_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !scenePause:
		velocity = Vector2(Input.get_axis("ui_left","ui_right"), Input.get_axis("ui_up","ui_down"))
		velocity = velocity.normalized()*movementSpeed
		move_and_slide()
		if velocity != Vector2(0,0):
			dialogueArea.position = Vector2(0,12)
			dialogueArea.position += velocity * hitboxOffset
			containersArea.position = Vector2(0,12)
			containersArea.position += velocity * hitboxOffset

signal advanceScene
var fastReload = false
var normalReload = false
var reloadTimer = 0.0
func _process(delta):
	reloadTimer += delta
	if fastReload and reloadTimer > 2.0:
		if bullets and bullets.quantity > 0:
			bulletsInGun = min(bullets.quantity,6)
			bullets.quantity -= bulletsInGun
			updateInv.emit([items,outfit,hasGun,bullets])
		fastReload = false
	if normalReload and reloadTimer > 1.0:
		if (bulletsInGun < 6) and bullets and bullets.quantity > 0:
			bulletsInGun += 1
			bullets.quantity -= 1
			updateInv.emit([items,outfit,hasGun,bullets])
			reloadTimer = 0
		else:
			normalReload = false
	
	if Input.is_action_just_pressed("Reload"):
		reload()
	
	#Debug give player bullets item
	if Input.is_action_just_pressed('Inventory'):
		var bulletItem = itemGenerator.makeItem('bullet')
		bulletItem.quantity = 99
		bullets = bulletItem
		updateInv.emit([items,outfit,hasGun,bullets])
		print(bullets.itemName + str(bullets.quantity))
	
	
	if Input.is_action_just_pressed("Interact"):
		if !scenePause:
			if !checkContainers():
				#print("test")
				checkDialogueNodes()
		else:
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
	$GunRay.target_position = Vector2.from_angle(playerPosition.angle_to_point(reticlePosition))*gunRange
	#ENABLE THIS TO VISUALIZE GUN RAYCAST
	#$GunRayDebug.points[1] = $GunRay.target_position

func fireGun():
	reload('cancel')
	if $"Aiming Reticle".visible and bulletsInGun > 0 and hasGun:
		bulletsInGun -= 1
		print("BANG: "+str(bulletsInGun))
		if $GunRay.is_colliding():
			print('is colliding' + $GunRay.get_collider().name)
			if $GunRay.get_collider().get('health'):
				$GunRay.get_collider().health -= gunDamage
				print('dealt damage')
		

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
			print(checkItem)
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
	updateInv.emit([items,outfit,hasGun,bullets])
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
