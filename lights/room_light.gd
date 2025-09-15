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

## A dict containing energy multipliers, keyed by id to allow multiple entities to edit their own multiplier
## Entities should use their own instance id as the identifier
## While a global multiplier with the lamp's instance id is present, it should not be edited directly.
## Use [code]global_multiplier[/code] instead
var energy_multipliers: Dictionary[int, float]
## A global multiplier
## When edited, changes the multiplier with the lamp's instance id in [code]energy_multipliers[/code]
var global_multiplier: float: set = _set_global_multiplier

## If [code]true[/code], the lamp is broken and doesn't emit any light
## Broken lamps can't be repaired
var broken: bool = false

func _ready() -> void:
	super._ready()
	global_multiplier = 1.0
	Game.lights_flicker.connect(flicker)
	
	# Store default light values
	for light in lights:
		default_energies[light] = light.light_energy
		
	
func _process(_delta: float) -> void:
	var global_mult = energy_multipliers.values().reduce(func(acc, val): return acc * val, 1.0)
	
	for light in lights:
		light.light_energy = default_energies[light] * global_mult
		
		
func _set_global_multiplier(multiplier: float) -> void:
	global_multiplier = multiplier
	energy_multipliers[self.get_instance_id()] = multiplier
		
func _set_broken(p_broken: bool) -> void:
	if broken:
		return
	else:
		if p_broken:
			light_break.emit()
	broken = p_broken
	
	
func set_multiplier(identifier: int, multiplier: float) -> void:
	energy_multipliers[identifier] = multiplier


func flicker(time: float) -> void:
	if broken:
		return
		
	# Generate energies and intervals
	var totalTime: float = 0
	var tween: Tween = self.create_tween()
	while totalTime < time:
		var interval: float = randf_range(MIN_INTERVAL, MAX_INTERVAL)
		totalTime += interval
		tween.tween_property(
			self,
			"global_multiplier",
			randf_range(MIN_ENERGY_MULT, MAX_ENERGY_MULT),
			interval
		)
	tween.tween_property(
		self,
		"global_multiplier",
		1.0,
		randf_range(MIN_ENERGY_MULT, MAX_ENERGY_MULT)
	)
	tween.tween_callback(flicker_end.emit)
	flicker_start.emit()


## Breaks the light
func break_light() -> void:
	if broken:
		return
		
	broken = true
	for light in lights:
		light.visible = false
	lights.clear()
