class_name Consumable
extends RefCounted

enum Type {
	BATTERY
}
	
@export var type: Type
@export var amount: int = 1
