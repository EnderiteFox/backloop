class_name MultiplierComponent
extends GenericComponent

signal multiplier_changed


@export var base_multiplier: float = 1.0:
	set = _set_base_multiplier


var _effects: Dictionary[int, float] = {}


func _set_base_multiplier(mult: float) -> void:
	base_multiplier = mult
	multiplier_changed.emit()


func set_effect_with_id(id: int, multiplier: float) -> void:
	_effects[id] = multiplier
	multiplier_changed.emit()
	
	
func set_effect(object: Object, multiplier: float) -> void:
	set_effect_with_id(object.get_instance_id(), multiplier)
	

func remove_effect_with_id(id: int) -> void:
	_effects.erase(id)
	multiplier_changed.emit()
	
	
func remove_effect(object: Object) -> void:
	remove_effect_with_id(object.get_instance_id())
	

func get_effect() -> float:
	return _effects.values().reduce(func(a: float, b: float) -> float: return a * b, base_multiplier)
