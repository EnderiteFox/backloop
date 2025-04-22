class_name PickRandomWeighted
extends Node
## Deletes all nodes except for a chosen amount, based on a weight
## Weight can be customized by using [RandomWeight]s
## All other nodes are treated as a weight of 1

@export var kept_nodes_amount: int = 1

func _ready() -> void:
	var children: Array[Node] = get_children()
	var chosen_nodes: Array[Node] = []
	
	for i in range(kept_nodes_amount):
		var chosen: float = randf_range(0.0, _get_total_weight(children))
		var current_value: float = 0.0
		for child in children:
			var node_weight: float = _get_node_weight(child)
			if node_weight + current_value >= chosen:
				children.erase(child)
				chosen_nodes.append(child)
				break
			current_value += node_weight
		
	assert(chosen_nodes.size() == kept_nodes_amount)
			
	for child in get_children():
		if child not in chosen_nodes:
			child.queue_free()
			
	
	
func _get_total_weight(nodes: Array[Node]) -> float:
	return nodes.reduce(
		func(accum, node):
			return accum + _get_node_weight(node),
		0.0
	)
	
	
func _get_node_weight(node: Node) -> float:
	if node is RandomWeight:
		return node.weight
	else:
		return 1.0
