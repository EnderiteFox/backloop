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


func _init() -> void:
	Game.lights_flicker.connect(flicker)
	
	
func get_effect() -> float:
	if broken:
		return 0.0
	else:
		return super.get_effect()


func flicker(time: float) -> void:
	if not ensure_manager_set():
		return

	if broken:
		return
		
	# Generate energies and intervals
	var totalTime: float = 0
	var tween: Tween = manager.create_tween()
	while totalTime < time:
		var interval: float = randf_range(flicker_min_interval, flicker_max_interval)
		totalTime += interval
		tween.tween_property(
			self,
			"base_multiplier",
			randf_range(flicker_min_mult, flicker_max_mult),
			interval
		)
	tween.tween_property(
		self,
		"base_multiplier",
		1.0,
		randf_range(flicker_min_interval, flicker_max_interval)
	)
	tween.tween_callback(flicker_end.emit)
	flicker_start.emit()
	
	
func break_light() -> void:
	if broken:
		return
		
	broken = true
	on_break.emit()
	multiplier_changed.emit()
