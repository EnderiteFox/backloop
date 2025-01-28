extends Node

const MIN_FLASHLIGHT_INTENSITY: float = 0.5
const MAX_FLASHLIGHT_INTENSITY: float = 1.0
const MIN_FLASHLIGHT_INTERVAL: float = 0.01
const MAX_FLASHLIGHT_INTERVAL: float = 0.2

func _ready() -> void:
	%AnimationPlayer.play("enter_game_over")
	_flicker_flashlight()

func _flicker_flashlight() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(
			%Flashlight,
			"light_energy",
			randf_range(MIN_FLASHLIGHT_INTENSITY, MAX_FLASHLIGHT_INTENSITY),
			randf_range(MIN_FLASHLIGHT_INTERVAL, MAX_FLASHLIGHT_INTERVAL)
	)
	tween.tween_callback(_flicker_flashlight)
