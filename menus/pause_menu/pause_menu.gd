class_name PauseMenu
extends Menu

const MAIN_MENU_SCENE: PackedScene = preload("uid://bev5ngmsob6ud")

@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton

@onready var settings_menu: SettingsMenu = %SettingsMenu


func _ready() -> void:
	continue_button.pressed.connect(close)
	settings_button.pressed.connect(open_submenu.bind(settings_menu))
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	
func _on_main_menu_button_pressed() -> void:
	self.close()
	get_tree().change_scene_to_packed(MAIN_MENU_SCENE)
	
	
func open() -> void:
	super.open()
	get_tree().paused = true
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	
	
func on_focus() -> void:
	super.on_focus()
	continue_button.grab_focus()
	
	
func close() -> void:
	super.close()
	get_tree().paused = false
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
