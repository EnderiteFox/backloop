class_name InventorySlotUI
extends Control


@onready var item_texture_rect: TextureRect = %ItemTexture
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func set_texture(texture: Texture2D) -> void:
	item_texture_rect.texture = texture
	
	
func select() -> void:
	animation_player.play(&"select")
	

func unselect() -> void:
	animation_player.play("unselect")
