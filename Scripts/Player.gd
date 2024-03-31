extends CharacterBody2D


const MovementSpeed = 100
const dialogueOffset = .18

@onready var dialogueArea = $Area2D
signal dialogueSignal
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(Input.get_axis("ui_left","ui_right"), Input.get_axis("ui_up","ui_down"))
	velocity = velocity.normalized()*MovementSpeed
	move_and_slide()
	if velocity != Vector2(0,0):
		dialogueArea.position = Vector2(0,12)
		dialogueArea.position += velocity * dialogueOffset
	#print(position)
	
func _process(delta):
	if Input.is_action_just_pressed("Interact"):
		checkDialogueNodes()

func checkDialogueNodes():
	var dialogueNodes = dialogueArea.get_overlapping_areas()
	if dialogueNodes.size() == 0:
		return
	var priorityDialogueNode = dialogueNodes[0]
	for dialogueNode in dialogueNodes:
		if dialogueNode.dialoguePriority > priorityDialogueNode.dialoguePriority:
			priorityDialogueNode = dialogueNode
	dialogueSignal.emit(priorityDialogueNode)
