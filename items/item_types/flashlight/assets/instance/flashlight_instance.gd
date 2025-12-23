class_name FlashlightInstance
extends ItemInstance


## The max consumption for the flash
const FLASH_CONSUMPTION: float = 20.0
## The duration of the flash
const FLASH_DURATION: float = 0.9
## The time between the flashlight turning on and the flash occuring
const FLASH_DELAY: float = 0.1


## Emitted when the flashlight starts flashing
signal flash_start
## Emitted when the flashlight stops flashing
signal flash_finished
## Emitted when the animation for reloading the battery is finished
signal battery_reload_finished


@export var battery_component: BatteryPoweredComponent
@export var toggleable_component: ToggleableComponent

## If [code]true[/code], the player can reload the flashlight
var can_reload: bool = true
var flashlight_in_hand: FlashlightInHand

var default_consumption: float

var flash_tween: Tween = null

func _ready() -> void:
	assert(self.item_in_hand is FlashlightInHand)
	flashlight_in_hand = self.item_in_hand
	
	default_consumption = toggleable_component.battery_consumption
	toggleable_component.toggled_on.connect(_on_turn_on)
	
	battery_component.battery_reloaded.connect(_on_reload)
	battery_component.can_reload_callable = func():
		return can_reload and is_selected
	
	
	toggleable_component.toggled_off.connect(_interrupt_flash_tween)
	battery_component.battery_ran_out.connect(_interrupt_flash_tween)
	battery_component.battery_reloaded.connect(_interrupt_flash_tween)
	
	battery_reload_finished.connect(_on_reload_finished)
	
	
func _on_reload() -> void:
	can_reload = false
	
	
func _on_turn_on() -> void:
	flash_start.emit()
	flash_tween = create_tween()
	flash_tween.tween_property(toggleable_component, "battery_consumption", FLASH_CONSUMPTION, FLASH_DELAY)
	flash_tween.tween_property(toggleable_component, "battery_consumption", default_consumption, FLASH_DURATION)
	flash_tween.tween_callback(flash_finished.emit)
	
	
func _on_reload_finished() -> void:
	can_reload = true
	
	
func _interrupt_flash_tween() -> void:
	if flash_tween == null:
		return
		
	flash_tween.kill()
	flash_tween = null
	toggleable_component.battery_consumption = default_consumption
