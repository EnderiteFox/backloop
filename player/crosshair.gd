extends Control


const FADE_TIME: float = 0.25

var tween: Tween
var looking_at_interactable: bool = false

var interaction_raycast: RayCast3D


func _ready() -> void:
	var parent: Node = get_parent()
	if not parent is Player:
		push_error("Parent of crosshair should be Player")
		self.free()
		return
	parent.ready.connect(
		func():
			interaction_raycast = (parent as Player).interaction_raycast
	)


func _physics_process(_delta: float) -> void:
	if interaction_raycast == null:
		return

	var raycast_collided: Object = interaction_raycast.get_collider()

	var new_looking_at_interactable: bool = raycast_collided is Interactable

	if new_looking_at_interactable == looking_at_interactable:
		return

	var modulate_color: Color = Color.WHITE if new_looking_at_interactable else Color.TRANSPARENT

	if tween != null:
		tween.kill()

	tween = self.create_tween()
	tween.tween_property(self, "modulate", modulate_color, FADE_TIME)
	tween.tween_callback(func(): tween = null)

	looking_at_interactable = new_looking_at_interactable
