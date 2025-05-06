class_name Item
extends Node3D

enum Type {
	FLASHLIGHT,
}

## Emitted when the item is selected
signal selected
## Emitted when the item is unselected
signal unselected
## Emitted from inventory when the item is picked up by the player
@warning_ignore("unused_signal")
signal picked_up

@export var inventory_texture: Texture2D
@export var item_type: Type

var is_selected: bool = false:
	set = set_selected


func set_selected(new_selected: bool) -> void:
	if is_selected == new_selected:
		return
	
	if new_selected:
		self.selected.emit()
	else:
		self.unselected.emit()
	
	is_selected = new_selected
