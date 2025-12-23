class_name FlashlightInHand
extends ItemInHand


const FLICKER_MIN_ENERGY: float = 0.45
const FLICKER_MAX_ENERGY: float = 0.55
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

var flicker_tween: Tween = null


func _ready() -> void:
	assert(self.item is FlashlightInstance)
	flashlight = self.item
	
	flashlight.picked_up.connect(animation_player.play.bind(ANIM_PICKUP))
	flashlight.selected.connect(animation_player.play.bind(ANIM_SELECT))
	flashlight.unselected.connect(animation_player.play.bind(ANIM_UNSELECT))
	flashlight.flash_finished.connect(_flicker)
	
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
	_interrupt_flicker_tween()
	
	
func _on_turn_off() -> void:
	animation_player.play(ANIM_TOGGLE_OFF)
	_interrupt_flicker_tween()
	
		
func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == ANIM_BATTERY_RELOAD:
		flashlight.battery_reload_finished.emit()
		
		
func _interrupt_flicker_tween() -> void:
	if flicker_tween == null:
		return
	
	flicker_tween.kill()
	flicker_tween = null
	
	
func _flicker() -> void:
	_interrupt_flicker_tween()
	flicker_tween = create_tween()
	flicker_tween.tween_property(
		flashlight_spotlight,
		"light_energy",
		randf_range(
			FLICKER_MIN_ENERGY,
			FLICKER_MAX_ENERGY
		),
		randf_range(
			FLICKER_MIN_INTERVAL,
			FLICKER_MAX_INTERVAL
		)
	)
	flicker_tween.tween_callback(_flicker)
