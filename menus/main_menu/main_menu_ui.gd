extends Menu

@onready var play_button: Button = %PlayButton

@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var settings_button: Button = %SettingsButton

func _ready() -> void:
	open()
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	
	
func close() -> void:
	pass
	
	
func on_focus() -> void:
	play_button.grab_focus()
	
	
func _on_play_button_pressed() -> void:
	if settings_button.pressed.is_connected(_on_settings_button_pressed):
		settings_button.pressed.disconnect(_on_settings_button_pressed)
	
	
func _on_settings_button_pressed() -> void:
	open_submenu(settings_menu)
