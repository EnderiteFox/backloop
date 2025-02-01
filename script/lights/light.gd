extends RoomElement
class_name Light

signal flicker_start
signal flicker_end

@export var lights: Array[Light3D]
@export var breakHitbox: Area3D

const MIN_ENERGY_MULT: float = 0
const MAX_ENERGY_MULT: float = 0.7
const MIN_INTERVAL: float = 0.05
const MAX_INTERVAL: float = 0.2

func _ready() -> void:
	super._ready()
	Game.lights_flicker.connect(flicker)
	breakHitbox.area_entered.connect(_on_lightbreaker_touched)

func flicker(time: float) -> void:
	for light in lights:
		_flicker_light(time, light)
	flicker_start.emit()
	get_tree().create_timer(time).timeout.connect(func(): flicker_end.emit())


func _on_lightbreaker_touched(_area: Area3D) -> void:
	if !room.fullyGenerated:
		return
	breakLight()

## Breaks the light
func breakLight() -> void:
	for light in lights:
		light.visible = false
	lights.clear()

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
