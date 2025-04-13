extends Item

@export var battery_component: BatteryPoweredComponent
@export var toggleable_component: ToggleableComponent

@onready var flashlight_spotlight: SpotLight3D = %FlashlightSpotLight
@onready var flashlight_model: Node3D = %FlashlightModel

func _ready() -> void:
	self.item_type = Type.FLASHLIGHT
	
	flashlight_spotlight.visible = false
	
	toggleable_component.toggled_on.connect(_on_toggle_on)
	toggleable_component.toggled_off.connect(_on_toggle_off)
	
	battery_component.battery_ran_out.connect(_on_battery_ran_out)
	
	self.selected.connect(_on_select.call_deferred)
	self.unselected.connect(_on_unselect.call_deferred)
	
	
func _on_unselect() -> void:
	self.model.visible = true
	self.flashlight_model.visible = false
	self.flashlight_spotlight.visible = toggleable_component.active
	
func _on_select() -> void:
	self.flashlight_model.visible = true
	self.flashlight_spotlight.visible = toggleable_component.active
	
	
func _on_toggle_on() -> void:
	flashlight_spotlight.visible = true
	
	
func _on_toggle_off() -> void:
	flashlight_spotlight.visible = false
	
	
func _on_battery_ran_out() -> void:
	# TODO: Make a correct animation for the flashlight running out of battery
	
	# FIXME: Change with correct animation
	_on_toggle_off()
