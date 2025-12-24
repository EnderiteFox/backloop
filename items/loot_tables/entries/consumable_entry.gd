class_name ConsumableEntry
extends LootTableEntry


@export var consumable: ConsumableInfo
@export var min_amount: int = 1
@export var max_amount: int = 1


func get_item() -> Array:
	return [consumable, randi_range(min_amount, max_amount)]
