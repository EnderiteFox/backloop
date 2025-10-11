class_name SettingsMenu
extends Menu

@onready var back_button: Button = %BackButton

@onready var sensibility_slider: Slider = %SensibilitySlider
@onready var sensibility_spinbox: SpinBox = %SensibilitySpinBox


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)


func _on_back_button_pressed() -> void:
	self.close()
