class_name BatteryPoweredComponent
extends ItemComponent

signal battery_ran_out

@export var max_battery: float = 1.0
@export var current_battery: float = 1.0:
	set = set_current_battery

func _ready() -> void:
	super._ready()
	item.selected.connect(_on_item_select)
	item.unselected.connect(_on_item_unselect)


func _on_item_select() -> void:
	var inventory_view: InventoryView = Game.player.inventory_view
	inventory_view.battery_bar.max_value = max_battery
	inventory_view.battery_bar.value = current_battery
	inventory_view.battery_bar_animation.play("show")
	
	
func _on_item_unselect() -> void:
	Game.player.inventory_view.battery_bar_animation.play("hide")


func set_current_battery(battery: float) -> void:
	if current_battery > 0.0 and battery <= 0.0:
		battery_ran_out.emit()
	current_battery = max(0.0, battery)
	
	if item.is_selected:
		Game.player.inventory_view.battery_bar.value = current_battery
