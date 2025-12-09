extends Node

const TITLE_MIN_BRIGHTNESS: float = 0.6
const TITLE_MAX_BRIGHTNESS: float = 1.0
const TITLE_MIN_BLINK_TIME: float = 0.1
const TITLE_MAX_BLINK_TIME: float = 0.3
const TITLE_MIN_BLINK_WAIT_TIME: float = 0.5
const TITLE_MAX_BLINK_WAIT_TIME: float = 1.5
const TITLE_MIN_BLINK_COUNT: int = 5
const TITLE_MAX_BLINK_COUNT: int = 8

@onready var title: Label3D = %Title
@onready var menu_music_player: AudioStreamPlayer = %MenuMusic
@onready var play_button: Button = %PlayButton
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var start_room: Room = %StartRoom


func _ready() -> void:
	_blink_title()
	start_room.visible = true
	menu_music_player.play()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	play_button.pressed.connect(_on_play_button_pressed)


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
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	play_button.disabled = true
	animation_player.play("play_fade_out")
	animation_player.animation_finished.connect(
		func(_anim):
			Game.reset()
			Game.room_list.load_room_infos()
			get_tree().change_scene_to_file("uid://of56mmim7b8x")
	)
