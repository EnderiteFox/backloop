class_name ConsumableInfo
extends BaseItemInfo

enum Type {
	BATTERY
}

@export var type: Type
@export var min_amount: int = 1
@export var max_amount: int = 1
