extends Node3D

func _ready() -> void:
	var children: Array[Node] = self.get_children()
	children.shuffle()
	for i in range(1, children.size()):
		children[i].free()
