extends Item

const FLICKER_ANIMATION_LIGHT_ENERGY_TRACK_PATH: NodePath = ^"%FlashlightSpotLight:light_energy"
const FLICKER_ANIMATION_MIN_ENERGY: float                 = 0.45
const FLICKER_ANIMATION_MAX_ENERGY: float                 = 0.55

const TOGGLE_ON_ANIMATION_DRAIN_TRACK_PATH: NodePath = ^"%FlashlightModel/../../ToggleableComponent:battery_consumption"
const TOGGLE_ON_ANIMATION_FLASH_TIME: float = 0.1

const FLASH_CONSUMPTION_VALUE: float = 20.0

@export var battery_component: BatteryPoweredComponent
@export var toggleable_component: ToggleableComponent

@onready var flashlight_spotlight: SpotLight3D = %FlashlightSpotLight
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	self.item_type = Type.FLASHLIGHT

	self.picked_up.connect(_on_pick_up)
	self.selected.connect(_on_selected)
	self.unselected.connect(_on_unselected)
	battery_component.battery_ran_out.connect(_on_battery_ran_out)
	battery_component.battery_reloaded.connect(_on_battery_reloaded)
	toggleable_component.toggled_on.connect(_on_turn_on)
	toggleable_component.toggled_off.connect(_on_turn_off)
	toggleable_component.toggle_fail_no_battery.connect(_on_turn_on_failed_no_battery)

	animation_player.animation_started.connect(_on_animation_start)
	animation_player.animation_finished.connect(_on_animation_finished)
	
	_set_animation_flash_drain_value()


func _set_animation_flash_drain_value() -> void:
	var anim: Animation = animation_player.get_animation(&"toggle_on")
	var track_index: int = anim.find_track(TOGGLE_ON_ANIMATION_DRAIN_TRACK_PATH, Animation.TrackType.TYPE_VALUE)
	if track_index == -1:
		push_error("Toggle on animation battery consumption track not found")
		return
		
	var keyframe_index: int = anim.track_find_key(
		track_index,
		TOGGLE_ON_ANIMATION_FLASH_TIME,
		Animation.FIND_MODE_NEAREST
	)
	if keyframe_index == -1:
		push_error("Toggle on animation battery consumption flash keyframe not found")
		return
	
	anim.track_set_key_value(track_index, keyframe_index, FLASH_CONSUMPTION_VALUE)
		

func _on_animation_start(animation_name: StringName) -> void:
	if animation_name == &"ambient_flicker":
		_set_random_flicker_animation_values()


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"toggle_on":
		animation_player.play(&"ambient_flicker")


func _set_random_flicker_animation_values() -> void:
	var anim: Animation  = animation_player.get_animation(&"ambient_flicker")
	var track_index: int = anim.find_track(FLICKER_ANIMATION_LIGHT_ENERGY_TRACK_PATH, Animation.TrackType.TYPE_VALUE)
	if track_index == -1:
		push_error("Flicker animation track not found")
		return
	var keyframe_count: int = anim.track_get_key_count(track_index)

	for i in range(keyframe_count):
		anim.track_set_key_value(
			track_index,
			i,
			randf_range(
				FLICKER_ANIMATION_MIN_ENERGY,
				FLICKER_ANIMATION_MAX_ENERGY
			)
		)


func _on_battery_ran_out() -> void:
	animation_player.play(&"battery_run_out")
	
	
func _on_battery_reloaded() -> void:
	animation_player.play(&"battery_reload")


func _on_selected() -> void:
	animation_player.play(&"select")


func _on_unselected() -> void:
	animation_player.play(&"unselect")


func _on_turn_on() -> void:
	animation_player.play(&"toggle_on")


func _on_turn_off() -> void:
	animation_player.play(&"toggle_off")


func _on_turn_on_failed_no_battery() -> void:
	animation_player.play(&"toggle_off")


func _on_pick_up() -> void:
	animation_player.play(&"pickup")
