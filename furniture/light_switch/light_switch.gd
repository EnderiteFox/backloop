class_name LightSwitch
extends Node3D


const ANIM_ROTATION: float = deg_to_rad(5.8)
const ANIM_LENGTH: float = 0.2


signal turned_on
signal turned_off
signal toggled


@export var is_on: bool = false:
	set(new_on):
		if new_on and not is_on:
			turned_on.emit()
			toggled.emit()
		elif not new_on and is_on:
			turned_off.emit()
			toggled.emit()
		is_on = new_on
		
var tween: Tween = null

@onready var switch: Node3D = %Switch
@onready var interactable: Interactable = %Interactable
@onready var toggle_sound: AudioStreamPlayer3D = %ToggleSound


func _ready() -> void:
	turned_on.connect(_on_turn_on)
	turned_off.connect(_on_turn_off)
	interactable.interacted.connect(_on_interacted)
	switch.rotation.z = ANIM_ROTATION if is_on else -ANIM_ROTATION
	
	
func _on_interacted() -> void:
	is_on = not is_on
	toggle_sound.play()
	
	
func _on_turn_on() -> void:
	_interrupt_tween()
	tween = create_tween()
	tween.tween_property(switch, "rotation:z", ANIM_ROTATION, ANIM_LENGTH)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(_interrupt_tween)
	
	
func _on_turn_off() -> void:
	_interrupt_tween()
	tween = create_tween()
	tween.tween_property(switch, "rotation:z", -ANIM_ROTATION, ANIM_LENGTH)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(_interrupt_tween)
	
	
func _interrupt_tween() -> void:
	if tween != null:
		tween.kill()
		tween = null
