class_name RoomLight
extends RoomElement

signal flicker_start
signal flicker_end

const MIN_ENERGY_MULT: float = 0
const MAX_ENERGY_MULT: float = 0.7
const MIN_INTERVAL: float = 0.05
const MAX_INTERVAL: float = 0.2

@export var lights: Array[Light3D]
@export var breakHitbox: Area3D

var default_energies: Dictionary[Light3D, float]

var energy: float = 1.0:
	set = set_energy

func _ready() -> void:
	super._ready()
	Game.lights_flicker.connect(flicker)
	breakHitbox.area_entered.connect(_on_lightbreaker_touched)
	
	# Store default light values
	for light in lights:
		default_energies[light] = light.light_energy
		
		
func set_energy(new_energy: float) -> void:
	energy = new_energy
	for light in lights:
		assert(default_energies.has(light), "Light has no default energy")
		light.light_energy = default_energies[light] * energy


func _on_lightbreaker_touched(_area: Area3D) -> void:
	if !room.fullyGenerated:
		return
	breakLight()


func _flicker_light(time: float, light: Light3D) -> void:
	var totalTime: float = 0
	var tween: Tween = self.create_tween()
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


func flicker(time: float) -> void:
	for light in lights:
		_flicker_light(time, light)
	flicker_start.emit()
	get_tree().create_timer(time).timeout.connect(flicker_end.emit)


## Breaks the light
func breakLight() -> void:
	for light in lights:
		light.visible = false
	lights.clear()
