class_name FlashlightInstance
extends ItemInstance


## Emitted when the animation for reloading the battery is finished
signal battery_reload_finished


@export var battery_component: BatteryPoweredComponent
@export var toggleable_component: ToggleableComponent

## If [code]true[/code], the player can reload the flashlight
var can_reload: bool = true
var flashlight_in_hand: FlashlightInHand

func _ready() -> void:
	assert(self.item_in_hand is FlashlightInHand)
	flashlight_in_hand = self.item_in_hand
	
	battery_component.battery_reloaded.connect(_on_reload)
	battery_component.can_reload_callable = func():
		return can_reload and is_selected
	
	battery_reload_finished.connect(_on_reload_finished)
	
	
func _on_reload() -> void:
	can_reload = false
	
	
func _on_reload_finished() -> void:
	can_reload = true
