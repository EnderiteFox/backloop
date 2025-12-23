## An instance of the item, representing its data and behaviour
class_name ItemInstance
extends Node

## Emitted when the item is picked up
@warning_ignore("unused_signal")
signal picked_up
## Emitted when the item is removed from the inventory
@warning_ignore("unused_signal")
signal removed
## Emitted when the item is selected in the hotbar
signal selected
## Emitted when the item is unselected in the hotbar, before the new item is selected
signal unselected


var is_selected: bool = false:
	set(new_selected):
		if new_selected and not is_selected:
			selected.emit()
		elif not new_selected and is_selected:
			unselected.emit()
		is_selected = new_selected
		
## The [code]ItemInfo[/code] for this item
var item_info: ItemInfo

## The visual representation of the item
## Sometimes used for items that need to interact with the world, like a flashlight
var item_in_hand: ItemInHand
