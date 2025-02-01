extends Light

@export var normalSound: AudioStreamPlayer3D
@export var flickerSound: AudioStreamPlayer3D

func _ready() -> void:
	super._ready()
	normalSound.play()
	flickerSound.stop()
	flicker_start.connect(_on_flicker)
	flicker_end.connect(_on_flicker_end)
	
func _on_flicker() -> void:
	flickerSound.play(normalSound.get_playback_position())
	normalSound.stop()

func _on_flicker_end() -> void:
	normalSound.play(flickerSound.get_playback_position())
	flickerSound.stop()
