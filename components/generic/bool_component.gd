class_name BoolComponent
extends GenericComponent

signal any_changed(new_val: bool)
signal all_changed(new_val: bool)

@export var base_value: bool = false:
	set = _set_base_value


var _true_values: Array[int] = []
var _false_values: Array[int] = []


func _set_base_value(val: bool) -> void:
	var prev_any: bool = self.any()
	var prev_all: bool = self.all()
	base_value = val
	var new_any: bool = self.any()
	var new_all: bool = self.all()
	
	if prev_any != new_any:
		any_changed.emit(new_any)
	if prev_all != new_all:
		all_changed.emit(new_all)
	
	
func set_value_with_id(id: int, value: bool) -> void:
	var prev_any: bool = self.any()
	var prev_all: bool = self.all()

	if value:
		_false_values.erase(id)
		if not id in _true_values:
			_true_values.append(id)
	else:
		_true_values.erase(id)
		if not id in _false_values:
			_false_values.append(id)
			
	var new_any: bool = self.any()
	var new_all: bool = self.all()
	
	if prev_any != new_any:
		any_changed.emit(new_any)
	if prev_all != new_all:
		all_changed.emit(new_all)
	
	
func set_value(object: Object, value: bool) -> void:
	set_value_with_id(object.get_instance_id(), value)
	
	
func remove_value_with_id(id: int) -> void:
	var prev_any: bool = self.any()
	var prev_all: bool = self.all()

	_true_values.erase(id)
	_false_values.erase(id)
	
	var new_any: bool = self.all()
	var new_all: bool = self.all()
	
	if prev_any != new_any:
		any_changed.emit(new_any)
	if prev_all != new_all:
		all_changed.emit(new_all)
	
	
func remove_value(object: Object) -> void:
	remove_value_with_id(object.get_instance_id())
	
	
func any() -> bool:
	return base_value or _true_values.size() > 0
	
	
func all() -> bool:
	return base_value and _false_values.size() == 0
