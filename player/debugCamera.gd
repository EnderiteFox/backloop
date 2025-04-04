extends Camera3D

const NORMAL_SPEED: float = 4.0
const FAST_SPEED: float = 10.0

const SENSIBILITY: float = 0.008

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_motion(event)
		return
	if event.is_action_pressed("freecam"):
		if !%DebugLight.visible:
			self.global_position = Game.player.camera.global_position
			self.global_rotation = Game.player.camera.global_rotation
			self.make_current()
			Game.player.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			Game.player.camera.make_current()
			Game.player.process_mode = Node.PROCESS_MODE_INHERIT
		%DebugLight.visible = !%DebugLight.visible


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var up_dir := 1 if Input.is_action_pressed("freecam_up") else -1 if Input.is_action_pressed("freecam_down") else 0
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	position.y += up_dir * get_speed() * delta
	
	if direction:
		position.x += direction.x * get_speed() * delta
		position.z += direction.z * get_speed() * delta


func _mouse_motion(event: InputEventMouseMotion) -> void:
	var motion: Vector2 = event.screen_relative
	rotation.y -= motion.x * SENSIBILITY
	rotation.x -= motion.y * SENSIBILITY
	rotation.x = clamp(rotation.x, -PI/2, PI/2)


func get_speed() -> float:
	return FAST_SPEED if Input.is_action_pressed("sprint") else NORMAL_SPEED
