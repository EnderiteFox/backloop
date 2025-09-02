class_name Flashable
extends Area3D

signal flashed

const FLASH_COLLISION_LAYER: int = 8
	
func _ready() -> void:
	self.set_collision_mask_value(8, true)
	self.area_entered.connect(_on_area_entered)
	
	
func _on_area_entered(area: Area3D) -> void:
	if area.get_collision_layer_value(FLASH_COLLISION_LAYER):
		flashed.emit()
