extends Node3D
## Deletes all child nodes except for one

func _ready() -> void:
	var children: Array[Node] = self.get_children()
	children.shuffle()
	for i in range(1, children.size()):
		children[i].free()
