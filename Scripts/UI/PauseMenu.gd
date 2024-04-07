extends PanelContainer

var menuButtonNode
var mainPauseMenuButtons = ['Resume Game','Save Game','Load Game','Options','Quit']
var optionsMenuButtons = ['placeholder','Return']
@onready var mainPauseMenu = $MarginContainer/MainPauseMenu
@onready var optionsMenu = $MarginContainer/OptionsMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	menuButtonNode = preload("res://Scenes/Instanced Objects/menu_button.tscn")
	for button in mainPauseMenuButtons:
		var buttonNode = menuButtonNode.instantiate()
		buttonNode.find_child("Label").text = button
		buttonNode.name = button
		mainPauseMenu.add_child(buttonNode)
		buttonNode.pressed.connect(_on_button_pressed.bind(buttonNode))
	for button in optionsMenuButtons:
		var buttonNode = menuButtonNode.instantiate()
		buttonNode.name = button
		buttonNode.find_child("Label").text = button
		optionsMenu.add_child(buttonNode)
		buttonNode.pressed.connect(_on_button_pressed.bind(buttonNode))

signal createManualSave
signal loadSave

var currentMenu = 'mainPause'
func _on_button_pressed(buttonNode):
	var button = buttonNode.name
	match currentMenu:
		'mainPause':
			match button:
				"Resume Game": self.visible = false
				"Save Game": createManualSave.emit()
				"Load Game": loadSave.emit()
				"Options": 
					mainPauseMenu.visible = false
					optionsMenu.visible = true
					currentMenu = 'options'
				"Quit": quitGame()
		'options':
			match button:
				'Return':
					mainPauseMenu.visible = true
					optionsMenu.visible = false
					currentMenu = 'mainPause'


func quitGame():
	SceneSwitcher.changeScene('res://Scenes/title_screen.tscn')
