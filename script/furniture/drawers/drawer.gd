class_name Drawer
extends Node3D

signal opened
signal closed
signal interacted

@export var hitbox: Interactable

@export var displacement: Vector3 = Vector3(40, 0, 0)
@export var open_sound: AudioStreamPlayer3D
@export var open_time: float = 0.5

var is_opened: bool = false
var disabled: bool = false

func _ready() -> void:
	opened.connect(
		func():
			interacted.emit()
			_on_opened()
	)
	closed.connect(
		func():
			interacted.emit()
			_on_closed()
	)

	hitbox.interacted.connect(
		func():
			if disabled:
				return
			if is_opened:
				closed.emit()
			else:
				opened.emit()
			is_opened = !is_opened
	)


func _on_opened() -> void:
	disabled = true
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "position", self.position + displacement, open_time)
	get_tree().create_timer(open_time).timeout.connect(func(): disabled = false)


func _on_closed() -> void:
	disabled = true
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "position", self.position - displacement, open_time)
	get_tree().create_timer(open_time).timeout.connect(func(): disabled = false)
