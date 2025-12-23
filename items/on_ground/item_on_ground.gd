## Gives an item to the player when interacted with
class_name ItemOnGround
extends BaseItemOnGround

var item_info: ItemInfo


func _on_pickup() -> void:
	if item_info == null:
		Game.print_error("Tried to pickup an item, but no ItemInfo was provided")
		return

	if Game.player.inventory.items.size() < Inventory.INVENTORY_SLOT_COUNT:
		Game.player.inventory.add_item(item_info)
		self.queue_free()
