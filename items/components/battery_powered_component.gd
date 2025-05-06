class_name BatteryPoweredComponent
extends ItemComponent

signal battery_ran_out
signal battery_reloaded

@export var max_battery: float = 1.0
@export var current_battery: float = 1.0:
	set = set_current_battery
@export var battery_recharge_amount: float = 1.0

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
	current_battery = clamp(battery, 0.0, max_battery)
	
	if item != null and item.is_selected:
		Game.player.inventory_view.battery_bar.value = current_battery
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight_recharge")\
	and Game.player.inventory.get_consumable_count(Consumable.Type.BATTERY) > 0\
	and item.is_selected:
		current_battery += battery_recharge_amount
		Game.player.inventory.add_consumable(Consumable.Type.BATTERY, -1)
		battery_reloaded.emit()
