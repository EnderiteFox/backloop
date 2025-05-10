extends Node3D

@onready var animationPlayer = %AnimationPlayer
@onready var audioStreamPlayer = %AudioStreamPlayer
@onready var theWatcher: TheWatcherModel = %TheWatcher

@onready var gameOverScene: PackedScene = preload("uid://c1hbjeqkobclu")

@onready var label: Label = %Label

var first_label_pos: Vector2
var labelCount: int = 0

const LABEL_DUPLICATE_DIRECTION: Vector2 = Vector2(0.005, -0.037)
const LABEL_COLUMN_DIRECTION: Vector2 = Vector2(0.52, -0.0463)

const LABEL_PER_COLUMN: int = 25

const LABEL_DUPLICATE_TIME: float = 0.05

func _ready() -> void:
	animationPlayer.play("jumpscare")
	animationPlayer.animation_finished.connect(
		func(_anim):
			get_tree().change_scene_to_packed(gameOverScene)
	)
	theWatcher.animationPlayer.play("jumpscare")
	audioStreamPlayer.play()
	label.label_settings.font_size = int(label.label_settings.font_size / 1920.0 * float(get_window().size.x))

func start_label_duplication() -> void:
	label.visible = true
	first_label_pos = label.global_position
	_duplicate_label()

func _duplicate_label() -> void:
	var newLabel: Label = label.duplicate()
	label.add_sibling(newLabel)
	labelCount += 1

	var posInColumn: int = labelCount % LABEL_PER_COLUMN
	@warning_ignore("integer_division")
	var columnIndex: int = (labelCount - posInColumn) / LABEL_PER_COLUMN

	newLabel.global_position = first_label_pos + LABEL_DUPLICATE_DIRECTION * posInColumn * Vector2(get_window().size) + LABEL_COLUMN_DIRECTION * columnIndex * Vector2(get_window().size)

	get_tree().create_timer(LABEL_DUPLICATE_TIME).timeout.connect(_duplicate_label)
