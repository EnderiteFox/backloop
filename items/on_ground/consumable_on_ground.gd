class_name ConsumableOnGround
extends BaseItemOnGround


@export var amount: int = 1
## Manually sets the item to give when picked up
## If empty, the consumable info should be set by the item spawner
@export var item_id: StringName

var consumable_info: ConsumableInfo


func _ready() -> void:
	super._ready()
	if not item_id.is_empty():
		if not Game.item_manager.consumable_infos.has(item_id):
			Game.print_warning("Consumable ", item_id, " is manually set in ItemOnGround but not loaded")
		else:
			consumable_info = Game.item_manager.consumable_infos[item_id]


func _on_pickup() -> void:
	if consumable_info == null:
		Game.print_error("Tried to pickup a consumable, but no ConsumableInfo was provided")
		return

	Game.player.inventory.add_consumable(consumable_info.type, amount)
	self.queue_free()
