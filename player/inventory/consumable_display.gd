extends Control

@export var inventory_view: InventoryView

@export var consumable_texture: Texture2D

@export var consumable_type: Consumable.Type

@onready var texture_rect: TextureRect = %ConsumableTexture
@onready var label: Label = %ConsumableCount
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	texture_rect.texture = consumable_texture
	inventory_view.inventory.consumable_count_changed.connect(_on_consumable_count_changed)
	
	
func _on_consumable_count_changed(old_amount: int, new_amount: int) -> void:
	if old_amount != 0 and new_amount == 0:
		animation_player.play("hide")
	elif old_amount == 0 and new_amount != 0:
		animation_player.play("show")
		
	label.text = str(new_amount)
