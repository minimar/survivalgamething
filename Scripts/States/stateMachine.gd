extends Node

@export var initialState: State

var stateDict = {}
var currentState: State

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_parent().ready
	for child in get_children():
		if child is State:
			stateDict[child.name.to_lower()] = child
			child.Transition.connect(changeState)
	if initialState:
		currentState = initialState
		currentState.enter()

func changeState(oldState,newState):
	
	newState = newState.to_lower()
	if oldState == stateDict[newState]:
		return
	if oldState != currentState:
		printerr('old state != currentState in statemachine')
		return
	currentState.exit()
	currentState = stateDict[newState]
	currentState.enter()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentState.update(delta)

func _physics_process(delta):
	currentState.physicsUpdate(delta)
