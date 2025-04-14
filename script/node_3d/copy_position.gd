extends Node3D

@export var position_parent: Node3D

func _process(_delta: float) -> void:
	self.global_basis = position_parent.global_basis
	self.global_position = position_parent.global_position
