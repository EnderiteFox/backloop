@abstract
class_name BaseItemOnGround
extends Node3D


@export var hitbox: Interactable


func _ready() -> void:
	hitbox.interacted.connect(_on_pickup)


@abstract
func _on_pickup() -> void
