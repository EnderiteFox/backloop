extends Node
## Chooses the selected amount of random_chance_templates and forces them to spawn
## This works by setting the spawn chance of the selected templates to 1

@export_range(0, 1, 1, "or_greater") var spawn_amount: int = 1

func _ready() -> void:
	if spawn_amount > get_child_count():
		push_error("Trying to spawn at least %s templates when there is only %s children" % [spawn_amount, get_child_count()])

	var random_templates: Array[RandomChanceTemplate] = []
	for node in get_children():
		if node is RandomChanceTemplate:
			random_templates.append(node)
	random_templates.shuffle()
	for i in range(spawn_amount):
		random_templates[i].spawn_chance = 1.0
