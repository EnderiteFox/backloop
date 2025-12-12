extends Node

# Title
const TITLE_MIN_BRIGHTNESS: float = 0.6
const TITLE_MAX_BRIGHTNESS: float = 1.0
const TITLE_MIN_BLINK_TIME: float = 0.1
const TITLE_MAX_BLINK_TIME: float = 0.3
const TITLE_MIN_BLINK_WAIT_TIME: float = 0.5
const TITLE_MAX_BLINK_WAIT_TIME: float = 1.5
const TITLE_MIN_BLINK_COUNT: int = 5
const TITLE_MAX_BLINK_COUNT: int = 8

# Easter Egg
const EASTER_EGG_CHANCE: float = 1.0 / 1000
const EASTER_EGG_DURATION: float = 3.0
const EASTER_EGG_AUDIO_LAG_LENGTH: float = 0.227
var easter_egg_audio_pos: float = 0

@onready var title: Label3D = %Title
@onready var menu_music_player: AudioStreamPlayer = %MenuMusic
@onready var play_button: Button = %PlayButton
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var start_room: Room = %StartRoom
@onready var ui: Control = %UI
@onready var easter_egg_node: Node3D = %EasterEgg


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
	
	if randf() < EASTER_EGG_CHANCE:
		_trigger_easter_egg()
		return
	
	animation_player.play("play_fade_out")
	animation_player.animation_finished.connect(
		func(_anim):
			Game.reset()
			Game.room_list.load_room_infos()
			get_tree().change_scene_to_file("uid://of56mmim7b8x")
	)
	
	
func _trigger_easter_egg() -> void:
	ui.visible = false
	ui.process_mode = Node.PROCESS_MODE_DISABLED
	title.process_mode = Node.PROCESS_MODE_DISABLED
	easter_egg_node.visible = true
	easter_egg_audio_pos = menu_music_player.get_playback_position()
	var timer := Timer.new()
	timer.autostart = true
	timer.wait_time = EASTER_EGG_AUDIO_LAG_LENGTH
	timer.timeout.connect(
		func():
			menu_music_player.seek(easter_egg_audio_pos)
	)
	easter_egg_node.add_child(timer)
	get_tree().create_timer(EASTER_EGG_DURATION).timeout.connect(get_tree().quit)
