class_name ItemOnGround
extends Node

@export var hitbox: Interactable
@export var item_scene: PackedScene


func _ready() -> void:
	hitbox.interacted.connect(_on_pickup)
	
	
func _on_pickup() -> void:
	Game.player.inventory.add_item(item_scene.instantiate())
	self.queue_free()
