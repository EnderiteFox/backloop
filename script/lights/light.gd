extends Node
class_name Light

signal flicker_start
signal flicker_end

@export var lights: Array[Light3D]

const MIN_ENERGY_MULT: float = 0
const MAX_ENERGY_MULT: float = 0.8
const MIN_INTERVAL: float = 0.05
const MAX_INTERVAL: float = 0.2

func flicker(time: float) -> void:
	for light in lights:
		_flicker_light(time, light)
	flicker_start.emit()
	get_tree().create_timer(time).timeout.connect(func(): flicker_end.emit())

func _flicker_light(time: float, light: Light3D) -> void:
	var totalTime: float = 0
	var tween: Tween = get_tree().create_tween()
	var lightEnergy: float = light.light_energy
	while totalTime < time:
		var interval: float = randf_range(MIN_INTERVAL, MAX_INTERVAL)
		totalTime += interval
		tween.tween_property(
			light,
			"light_energy",
			lightEnergy * randf_range(MIN_ENERGY_MULT, MAX_ENERGY_MULT),
			interval
		)
	tween.tween_property(
		light,
		"light_energy",
		lightEnergy,
		randf_range(MIN_ENERGY_MULT, MAX_ENERGY_MULT)
	)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		flicker(10)
