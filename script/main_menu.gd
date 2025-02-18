extends Node

@onready var title: Label3D = %Title
@onready var menuMusicPlayer: AudioStreamPlayer = %MenuMusic
@onready var playButton: Button = %PlayButton
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

@onready var mainGameScene: PackedScene = preload("res://scene/main_game.tscn")


const TITLE_MIN_BRIGHTNESS: float = 0.6
const TITLE_MAX_BRIGHTNESS: float = 1.0
const TITLE_MIN_BLINK_TIME: float = 0.1
const TITLE_MAX_BLINK_TIME: float = 0.3
const TITLE_MIN_BLINK_WAIT_TIME: float = 0.5
const TITLE_MAX_BLINK_WAIT_TIME: float = 1.5
const TITLE_MIN_BLINK_COUNT: int = 5
const TITLE_MAX_BLINK_COUNT: int = 8

func _ready() -> void:
	_blink_title()
	%StartRoom.visible = true
	menuMusicPlayer.play()
	playButton.pressed.connect(_on_play_button_pressed)


func _blink_title() -> void:
	var tween: Tween = title.create_tween()
	for i in range(randi_range(TITLE_MIN_BLINK_COUNT, TITLE_MAX_BLINK_COUNT)):
		var brightness: float = randf_range(TITLE_MIN_BRIGHTNESS, TITLE_MAX_BRIGHTNESS)
		tween.tween_property(
			title,
			"modulate",
			Color(brightness, brightness, brightness, 1.0),
			randf_range(TITLE_MIN_BLINK_TIME, TITLE_MAX_BLINK_TIME)
		)

	tween.tween_property(
		title,
		"modulate",
		Color.WHITE,
		randf_range(TITLE_MIN_BLINK_TIME, TITLE_MAX_BLINK_TIME)
	)
	tween.tween_interval(randf_range(TITLE_MIN_BLINK_WAIT_TIME, TITLE_MAX_BLINK_WAIT_TIME))
	tween.tween_callback(_blink_title)


func _on_play_button_pressed() -> void:
	playButton.disabled = true
	animationPlayer.play("play_fade_out")
	animationPlayer.animation_finished.connect(
		func(_anim):
			get_tree().change_scene_to_packed(mainGameScene)
	)

