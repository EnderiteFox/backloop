class_name BatteryPoweredComponent
extends ItemComponent

signal battery_ran_out

@export var max_battery: float = 1.0
@export var current_battery: float = 1.0:
	set = set_current_battery

func set_current_battery(battery: float) -> void:
	if current_battery > 0.0 and battery <= 0.0:
		battery_ran_out.emit()
	current_battery = max(0.0, battery)
