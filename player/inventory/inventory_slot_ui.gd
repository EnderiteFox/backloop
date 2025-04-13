class_name InventorySlotUI
extends Control

func set_texture(texture: Texture2D) -> void:
	%ItemTexture.texture = texture
	
	
func select() -> void:
	%AnimationPlayer.play("select")
	

func unselect() -> void:
	%AnimationPlayer.play("unselect")
