class_name LightEnergyComponent
extends MultiplierComponent


signal flicker_start
signal flicker_end
signal on_break

@export var flicker_min_mult: float = 0
@export var flicker_max_mult: float = 0.7
@export var flicker_min_interval: float = 0.05
@export var flicker_max_interval: float = 0.2

@export var can_break: bool = false

var broken: bool = false

var flicker_tween: Tween = null

var _flicker_bool: BoolComponent = BoolComponent.new()
var _remaining_flicker_time: float = 0.0


func _init() -> void:
	Game.lights_flicker.connect(flicker)
	self._flicker_bool.any_changed.connect(_on_flicker_bool_change)
	
	self.flicker_start.connect(_start_flicker_tween)
	
	
func tick(delta: float) -> void:
	var was_flickering: bool = is_flickering()
	self._remaining_flicker_time = max(0.0, self._remaining_flicker_time - delta)
	if not is_flickering() and was_flickering:
		flicker_end.emit()
	
	
func get_effect() -> float:
	if broken:
		return 0.0
	else:
		return super.get_effect()


func set_flicker(object: Object, p_is_flickering: bool) -> void:
	_flicker_bool.set_value(object, p_is_flickering)
	

func flicker(time: float) -> void:
	if is_zero_approx(self._remaining_flicker_time) and not _flicker_bool.any() and time > 0.0:
		flicker_start.emit()
		
	self._remaining_flicker_time = max(self._remaining_flicker_time, time)
	
	
func is_flickering() -> bool:
	return _flicker_bool.any() or not is_zero_approx(self._remaining_flicker_time)
	
	
func _on_flicker_bool_change(new_any: bool) -> void:
	if new_any and is_zero_approx(self._remaining_flicker_time):
		flicker_start.emit()
	elif not new_any and is_zero_approx(self._remaining_flicker_time):
		flicker_end.emit()
	
	
func _on_flicker_tween_end() -> void:
	flicker_tween = null

	if self.is_flickering():
		_start_flicker_tween()
		return
	
	flicker_tween = manager.create_tween()
	flicker_tween.tween_property(
		self,
		"base_multiplier",
		1.0,
		randf_range(flicker_min_interval, flicker_max_interval)
	)
	flicker_tween.finished.connect(_on_flicker_tween_end)
		
		
func _start_flicker_tween() -> void:
	if not ensure_manager_set():
		return
		
	if broken:
		return
		
	flicker_tween = manager.create_tween()
	flicker_tween.tween_property(
		self,
		"base_multiplier",
		randf_range(flicker_min_mult, flicker_max_mult),
		randf_range(flicker_min_interval, flicker_max_interval)
	)
	flicker_tween.finished.connect(_on_flicker_tween_end)
	
	
func break_light() -> void:
	if not can_break or broken:
		return
		
	broken = true
	base_multiplier = 0
	on_break.emit()
	multiplier_changed.emit()
