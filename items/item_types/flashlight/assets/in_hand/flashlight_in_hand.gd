class_name FlashlightInHand
extends ItemInHand

const BASE_ENERGY: float = 0.55

const FLICKER_MIN_ENERGY_MULT: float = 0.8
const FLICKER_MAX_ENERGY_MULT: float = 1.0
const FLICKER_MIN_INTERVAL: float = 0.075
const FLICKER_MAX_INTERVAL: float = 0.125

const ANIM_PICKUP: StringName = &"pickup"
const ANIM_SELECT: StringName = &"select"
const ANIM_UNSELECT: StringName = &"unselect"
const ANIM_TOGGLE_ON: StringName = &"toggle_on"
const ANIM_TOGGLE_OFF: StringName = &"toggle_off"
const ANIM_BATTERY_RELOAD: StringName = &"battery_reload"
const ANIM_BATTERY_RUN_OUT: StringName = &"battery_run_out"


@onready var flashlight_spotlight: SpotLight3D = %FlashlightSpotLight
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var flashlight: FlashlightInstance

var _ambient_flicker_tween: Tween = null

var component_manager: ComponentManager
var light_energy_component: LightEnergyComponent

var _energy_multiplier: float = 1.0:
	set = _set_energy_multiplier


func _ready() -> void:
	assert(self.item is FlashlightInstance)
	flashlight = self.item
	
	flashlight_spotlight.light_energy = BASE_ENERGY
	
	flashlight.picked_up.connect(animation_player.play.bind(ANIM_PICKUP))
	flashlight.selected.connect(animation_player.play.bind(ANIM_SELECT))
	flashlight.unselected.connect(animation_player.play.bind(ANIM_UNSELECT))
	
	component_manager = ComponentManager.new()
	self.add_child(component_manager)
	
	light_energy_component = LightEnergyComponent.new()
	component_manager.register(ComponentId.LightEnergy, light_energy_component)
	
	light_energy_component.multiplier_changed.connect(_on_light_energy_changed)
	
	var battery_component: BatteryPoweredComponent = flashlight.battery_component
	battery_component.battery_ran_out.connect(_on_battery_ran_out)
	battery_component.battery_reloaded.connect(animation_player.play.bind(ANIM_BATTERY_RELOAD))
	
	var toggleable_component: ToggleableComponent = flashlight.toggleable_component
	toggleable_component.toggled_on.connect(animation_player.play.bind(ANIM_TOGGLE_ON))
	toggleable_component.toggled_off.connect(_on_turn_off)
	toggleable_component.toggle_fail_no_battery.connect(animation_player.play.bind(ANIM_TOGGLE_OFF))
	
	animation_player.animation_finished.connect(_on_animation_finished)
	
	
func _on_battery_ran_out() -> void:
	animation_player.play(ANIM_BATTERY_RUN_OUT)
	_interrupt_ambient_flicker_tween()
	
	
func _on_turn_off() -> void:
	animation_player.play(ANIM_TOGGLE_OFF)
	_interrupt_ambient_flicker_tween()
	
		
func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == ANIM_BATTERY_RELOAD:
		flashlight.battery_reload_finished.emit()
	elif animation_name == ANIM_TOGGLE_ON:
		_ambient_flicker()
		
		
func _interrupt_ambient_flicker_tween() -> void:
	if _ambient_flicker_tween == null:
		return
	
	_ambient_flicker_tween.kill()
	_ambient_flicker_tween = null
	
	
func _on_light_energy_changed() -> void:
	flashlight_spotlight.light_energy = max(0, BASE_ENERGY * light_energy_component.get_effect())
	
	
func _set_energy_multiplier(val: float) -> void:
	_energy_multiplier = val
	light_energy_component.set_effect(self, _energy_multiplier)
	
	
func _ambient_flicker() -> void:
	_interrupt_ambient_flicker_tween()
	_ambient_flicker_tween = create_tween()
	_ambient_flicker_tween.tween_property(
		self,
		^"_energy_multiplier",
		randf_range(
			FLICKER_MIN_ENERGY_MULT,
			FLICKER_MAX_ENERGY_MULT
		),
		randf_range(
			FLICKER_MIN_INTERVAL,
			FLICKER_MAX_INTERVAL
		)
	)
	_ambient_flicker_tween.tween_callback(_ambient_flicker)
