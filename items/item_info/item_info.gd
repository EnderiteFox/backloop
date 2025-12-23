## Stores information about an item type
class_name ItemInfo
extends BaseItemInfo

enum Type {
	FLASHLIGHT
}

## The type of the object
@export var type: Type
## The scene of the [code]ItemInstance[/code]
## Is instantiated and added to the player
@export var item_scene: PackedScene
## The scene of the [code]ItemInHand[/code]
## Is instantiated and attached to the camera
@export var in_hand_scene: PackedScene
## The texture to display in inventory slots
@export var inventory_texture: Texture2D


## Returns an array containing the [code]ItemInstance[/code] and the [code]ItemInHand[/code]
## after instantiating the item
## Does not emit the [code]ItemInstance.picked_up[/code] signal
func to_instance() -> Array:
	var item_instance: ItemInstance = self.item_scene.instantiate()
	item_instance.item_info = self
	
	var item_in_hand: ItemInHand = self.in_hand_scene.instantiate()
	item_instance.item_in_hand = item_in_hand
	item_in_hand.item = item_instance
	
	return [item_instance, item_in_hand]
