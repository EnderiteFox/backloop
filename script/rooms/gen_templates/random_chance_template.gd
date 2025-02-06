extends Node
class_name RandomChanceTemplate
## Deletes the node if a random chance condition is not met

## The chance that the node spawns
@export_range(0.0, 1.0, 0.05) var spawn_chance: float = 1.0

func _ready() -> void:
	if randf() > spawn_chance:
		self.free()
