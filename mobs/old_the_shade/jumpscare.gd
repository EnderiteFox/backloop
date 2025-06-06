extends Node

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var game_over_scene: PackedScene = preload("uid://c1hbjeqkobclu")

func _ready() -> void:
	get_tree().paused = false
	animation_player.play(&"jumpscare")
	
	animation_player.animation_finished.connect(_on_animation_finished.unbind(1))
	
func _on_animation_finished() -> void:
	get_tree().change_scene_to_packed(game_over_scene)
