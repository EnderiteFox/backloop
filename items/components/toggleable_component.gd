class_name ToggleableComponent
extends ItemComponent

## Emitted when the item is toggled on
signal toggled_on

## Emitted when the item is toggled off.
## [b]Note:[/b] This signal is not emitted if the item runs out of battery.
## Listen to [battery_ran_out] in the [BatteryPoweredComponent] instead.
signal toggled_off

## Emitted when the item tries to turn on, but it has no battery
signal toggle_fail_no_battery

@export var active: bool = false

@export_group("Controls")
## The action to toggle on the item when the item is selected
@export var toggle_on_action: StringName
## The action to toggle off the item when the item is selected
@export var toggle_off_action: StringName
## If true, the item won't be turned off when it is unselected
@export var global_item: bool = false
## The action to toggle on the item even when the item is not selected
@export var toggle_on_global_action: StringName
## The action to toggle off the item even when the item is not selected
@export var toggle_off_global_action: StringName

@export_group("Battery Consumption")
@export var battery_component: BatteryPoweredComponent
@export_custom(PROPERTY_HINT_NONE, "suffix:/s") var battery_consumption: float


func _ready() -> void:
	super._ready()
	
	if battery_component != null:
		battery_component.battery_ran_out.connect(func(): active = false)
		
	self.item.unselected.connect(_on_item_unselected)

	
func _physics_process(delta: float) -> void:
	if battery_component == null:
		return
		
	if active:
		battery_component.current_battery -= battery_consumption * delta
	
	
func _unhandled_input(event: InputEvent) -> void:
	if active:
		if (item.is_selected and event.is_action_pressed(toggle_off_action))\
		or (global_item and event.is_action_pressed(toggle_off_global_action)):
			toggle_off()
	else:
		if (item.is_selected and event.is_action_pressed(toggle_on_action))\
		or (global_item and event.is_action_pressed(toggle_on_global_action)):
			if battery_component != null and battery_component.current_battery == 0.0:
				toggle_fail_no_battery.emit()
			else:
				toggle_on()
				
				
func toggle_on() -> void:
	toggled_on.emit()
	active = true
	

func toggle_off() -> void:
	toggled_off.emit()
	active = false
			
			
func _on_item_unselected() -> void:
	if not global_item:
		toggle_off()
