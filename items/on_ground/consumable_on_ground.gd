class_name ConsumableOnGround
extends BaseItemOnGround


var amount: int = 1
var consumable_info: ConsumableInfo


func _on_pickup() -> void:
	if consumable_info == null:
		Game.print_error("Tried to pickup a consumable, but no ConsumableInfo was provided")
		return

	Game.player.inventory.add_consumable(consumable_info.type, amount)
	self.queue_free()
