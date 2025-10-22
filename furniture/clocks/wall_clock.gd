extends Clock

const ADDITIONAL_ROTATIONS: int = 5

const TRANSITION: Tween.TransitionType = Tween.TRANS_CUBIC
const EASING: Tween.EaseType = Tween.EASE_OUT
const HAND_ANIM_TIME: float = 4.0

const WAIT_AFTER_DOOR: float = 2.0
const MOVE_SUBDIVISIONS: int = 3
const SUBDIVISION_WAIT: float = 0.2
const SUBDIVISION_TIME: float = 0.1

@onready var minute_hand: Node3D = %la_2
@onready var hour_hand: Node3D = %le_2

@onready var tick_low_sound: AudioStreamPlayer3D = %TickLowSound
@onready var tick_high_sound: AudioStreamPlayer3D = %TickHighSound

func update_time(new_time: int, animate: bool = true) -> void:
	if animate:
		var minute_rotation_delta: float = (((new_time - displayed_time) % 60) / 60.0) * TAU
	
		var minute_tween: Tween = self.create_tween()
		minute_tween.tween_interval(WAIT_AFTER_DOOR)
		for i in range(1, MOVE_SUBDIVISIONS):
			minute_tween.tween_callback(tick_low_sound.play)
			minute_tween.tween_property(
				minute_hand, 
				"rotation:z", 
				minute_rotation_delta / MOVE_SUBDIVISIONS, 
				SUBDIVISION_TIME
			).as_relative().set_trans(Tween.TransitionType.TRANS_CUBIC)
			minute_tween.tween_interval(SUBDIVISION_WAIT)
			
		minute_tween.tween_callback(tick_high_sound.play)
		minute_tween.tween_property(
			minute_hand,
			"rotation:z",
			minute_rotation_delta / MOVE_SUBDIVISIONS,
			SUBDIVISION_TIME
		).as_relative().set_trans(Tween.TransitionType.TRANS_CUBIC)
			
		var hour_rotation_delta: float = ((new_time - displayed_time) / 60.0 / 12.0) * TAU
	
		var hour_tween: Tween = self.create_tween()
		hour_tween.tween_interval(WAIT_AFTER_DOOR)
		for i in range(1, MOVE_SUBDIVISIONS + 1):
			hour_tween.tween_property(
				hour_hand, 
				"rotation:z", 
				hour_rotation_delta / MOVE_SUBDIVISIONS, 
				SUBDIVISION_TIME
			).as_relative().set_trans(Tween.TransitionType.TRANS_CUBIC)
			hour_tween.tween_interval(SUBDIVISION_WAIT)
	else:
		minute_hand.rotation.z = ((new_time % 60) / 60.0) * TAU
		hour_hand.rotation.z = (new_time / 60.0 / 12.0) * TAU

	super.update_time(new_time, animate)
