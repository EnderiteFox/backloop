class_name RoomLight
extends RoomElement

signal flicker_start
signal flicker_end

const MIN_ENERGY_MULT: float = 0
const MAX_ENERGY_MULT: float = 0.7
const MIN_INTERVAL: float = 0.05
const MAX_INTERVAL: float = 0.2

signal light_break

@export var lights: Array[Light3D]

var default_energies: Dictionary[Light3D, float]

var energy: float = 1.0:
	set = set_energy

var broken: bool = false

func _ready() -> void:
	super._ready()
	Game.lights_flicker.connect(flicker)
	
	# Store default light values
	for light in lights:
		default_energies[light] = light.light_energy
		
		
func _set_broken(p_broken: bool) -> void:
	if broken:
		return
	else:
		if p_broken:
			light_break.emit()
	broken = p_broken
		
		
func set_energy(new_energy: float) -> void:
	if broken:
		return
		
	energy = new_energy
	for light in lights:
		assert(default_energies.has(light), "Light has no default energy")
		light.light_energy = default_energies[light] * energy


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
	if broken:
		return
		
	# Generate energies and intervals
	var total_time: float = 0
	var intervals: Array[float]
	var energy_mults: Array[float]
	var end_interval: float = randf_range(MIN_INTERVAL, MAX_INTERVAL)
	while total_time < time:
		var interval: float = randf_range(MIN_INTERVAL, MAX_INTERVAL)
		intervals.append(interval)
		energy_mults.append(randf_range(MIN_ENERGY_MULT, MAX_ENERGY_MULT))
		total_time += interval
		
	# Create tweens
	for light in lights:
		var tween: Tween = light.create_tween()
		for i in range(intervals.size()):
			tween.tween_property(
				light,
				"light_energy",
				default_energies.get_or_add(light, 0.0) * energy_mults[i],
				intervals[i]
			)
		tween.tween_property(
			light,
			"light_energy",
			default_energies.get_or_add(light, 0.0),
			end_interval
		)
		light_break.connect(tween.kill)
		
	flicker_start.emit()
	get_tree().create_timer(total_time + end_interval).timeout.connect(flicker_end.emit)


## Breaks the light
func break_light() -> void:
	if broken:
		return
		
	broken = true
	for light in lights:
		light.visible = false
	lights.clear()
