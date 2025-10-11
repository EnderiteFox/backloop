class_name SettingsMenu
extends Menu

@onready var back_button: Button = %BackButton
@onready var tab_bar: TabBar = %TabBar


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	
	
func open() -> void:
	super.open()
	
	
func on_focus() -> void:
	super.on_focus()
	tab_bar.grab_focus()


func _on_back_button_pressed() -> void:
	self.close()
