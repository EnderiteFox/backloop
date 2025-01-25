extends RoomElement
class_name Door

signal opened

const CAMERA_TRANSITION_TIME: float = 0.1

var locked: bool = false:
	set(new_locked):
		locked = new_locked
		%LockedModel.visible = new_locked
		

var nextRoom: Room = null

func _ready() -> void:
	%InteractionHitbox.interacted.connect(_on_interact, ConnectFlags.CONNECT_ONE_SHOT)
	%AnimationPlayer.animation_finished.connect(func(_animation): _on_fully_opened())

func _on_interact() -> void:
	if locked:
		return
	opened.emit()
	nextRoom.room_opened.emit()
	var camera: Camera3D = Camera3D.new()
	self.add_child(camera)
	camera.make_current()
	var tween: Tween = get_tree().create_tween().set_parallel()
	tween.tween_property(
		camera,
		"global_position",
		%OpenCamera.global_position,
		CAMERA_TRANSITION_TIME
	).from(Game.player.camera.global_position)
	tween.tween_property(
		camera,
		"global_rotation",
		%OpenCamera.global_rotation,
		CAMERA_TRANSITION_TIME
	).from(Game.player.camera.global_rotation)
	tween.set_parallel(false)
	tween.tween_callback(
		func():
			_on_camera_tween_finished()
			camera.queue_free()
	)

func _on_camera_tween_finished() -> void:
	%OpenCamera.make_current()
	%AnimationPlayer.play("Door/open")
	
func _on_fully_opened() -> void:
	Game.player.camera.make_current()
	Game.player.position = %PlayerTeleport.global_position
	Game.player.rotation = %PlayerTeleport.global_rotation
	Game.player.camPivot.rotation.x = %OpenCamera.global_rotation.x
