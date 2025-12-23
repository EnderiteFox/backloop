## Gives an item to the player when interacted with
class_name ItemOnGround
extends BaseItemOnGround

## Forces the item to give when picked up
## If empty, the item info should be set by the item spawner
@export var item_id: StringName

var item_info: ItemInfo

func _ready() -> void:
	super._ready()
	if not item_id.is_empty():
		if not Game.item_manager.item_infos.has(item_id):
			Game.print_warning("Item ", item_id, " was manually set in ItemOnGround but is not loaded")
		else:
			item_info = Game.item_manager.item_infos[item_id]
		
	
func _on_pickup() -> void:
	if item_info == null:
		Game.print_error("Tried to pickup an item, but no ItemInfo was provided")
		return

	if Game.player.inventory.items.size() < Inventory.INVENTORY_SLOT_COUNT:
		Game.player.inventory.add_item(item_info)
		self.queue_free()
