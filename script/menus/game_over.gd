extends Node

const MIN_FLASHLIGHT_INTENSITY: float = 0.5
const MAX_FLASHLIGHT_INTENSITY: float = 1.0
const MIN_FLASHLIGHT_INTERVAL: float = 0.01
const MAX_FLASHLIGHT_INTERVAL: float = 0.2

const gameScene: PackedScene = preload("res://scene/main_game.tscn")
const menuScene: PackedScene = preload("res://scene/main_menu.tscn")

@onready var retryButton: Button = %RetryButton
@onready var mainMenuButton: Button = %MainMenuButton

func _ready() -> void:
	%AnimationPlayer.play("enter_game_over")
	_flicker_flashlight()
	retryButton.pressed.connect(_on_retry_button_pressed)
	mainMenuButton.pressed.connect(_on_main_menu_button_pressed)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _flicker_flashlight() -> void:
	var tween: Tween = self.create_tween()
	tween.tween_property(
			%Flashlight,
			"light_energy",
			randf_range(MIN_FLASHLIGHT_INTENSITY, MAX_FLASHLIGHT_INTENSITY),
			randf_range(MIN_FLASHLIGHT_INTERVAL, MAX_FLASHLIGHT_INTERVAL)
	)
	tween.tween_callback(_flicker_flashlight)

func _on_retry_button_pressed() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	%AnimationPlayer.play("exit_game_over")
	%AnimationPlayer.animation_finished.connect(func(_anim): _restart_game())

func _on_main_menu_button_pressed() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	%AnimationPlayer.play("exit_game_over")
	%AnimationPlayer.animation_finished.connect(
		func(_anim):
			get_tree().change_scene_to_packed(menuScene)
	)


func _restart_game() -> void:
	Game.reset()
	get_tree().change_scene_to_packed(gameScene)
