class_name ItemComponent
extends Node

var item: ItemInstance

func _ready() -> void:
	var node_parent: Node = self.get_parent()
	assert(node_parent is ItemInstance)
	item = node_parent as ItemInstance
