class_name ItemComponent
extends Node

var item: Item

func _ready() -> void:
	var node_parent: Node = self.get_parent()
	assert(node_parent is Item)
	item = node_parent as Item
