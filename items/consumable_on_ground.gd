class_name ConsumableOnGround
extends Node

@export var hitbox: Interactable
@export var type: Consumable.Type
@export var amount: int = 1


func _ready() -> void:
	hitbox.interacted.connect(_on_pickup)


func _on_pickup() -> void:
	Game.player.inventory.add_consumable(type, amount)
	self.queue_free()
