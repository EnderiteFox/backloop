extends Clock

const ADDITIONAL_ROTATIONS: int = 5

const TRANSITION: Tween.TransitionType = Tween.TRANS_CUBIC
const EASING: Tween.EaseType = Tween.EASE_OUT
const HAND_ANIM_TIME: float = 4.0

@onready var minute_hand: Node3D = %la_2
@onready var hour_hand: Node3D = %le_2

func update_time(new_time: int, animate: bool = true) -> void:
	var minute_rotation: Vector3 = Vector3(
		minute_hand.rotation.x,
		minute_hand.rotation.y,
		(((new_time) % 60) / 60.0) * 2 * PI
   	)
	while minute_rotation.z < minute_hand.rotation.z:
		minute_rotation.z += 2 * PI
	minute_rotation.z += ADDITIONAL_ROTATIONS * 2 * PI * int(60 / 12.0)
	var minuteTween: Tween = self.create_tween()
	minuteTween.tween_property(minute_hand, "rotation", minute_rotation, HAND_ANIM_TIME if animate else 0.0) \
		.set_trans(TRANSITION) \
		.set_ease(EASING)

	var hour_rotation: Vector3 = Vector3(
		hour_hand.rotation.x,
		hour_hand.rotation.y,
		(new_time / 60.0 / 12.0) * 2 * PI
	)
	while hour_rotation.z < hour_hand.rotation.z:
		hour_rotation.z += 2 * PI
	hour_rotation.z += ADDITIONAL_ROTATIONS * 2 * PI
	var hourTween: Tween = self.create_tween()
	hourTween.tween_property(hour_hand, "rotation", hour_rotation, HAND_ANIM_TIME if animate else 0.0) \
		.set_trans(TRANSITION) \
		.set_ease(EASING)

	super.update_time(new_time, animate)
