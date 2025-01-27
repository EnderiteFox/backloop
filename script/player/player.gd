extends CharacterBody3D
class_name Player

@warning_ignore("unused_signal")
signal died

const SPEED = 2.0
const SPRINTSPEED = 5
const CROUCHSPEED = 1
const SENSIBILITY: float = 0.008

const VIEW_BOBBLE_AMOUNT: float = 0.08
const VIEW_BOBBLE_SPEED = 3.5
var view_bobble_progress: float = 0.0

const INTERACTION_RANGE: float = 2.0

const EXHAUSTION = 4
const STAMINA_DRAIN = 30
const STAMINA_GAIN = 30
var exhaustion = 0
var stamina: float = 100.0

var currentCrouchCamOffset: float = 0
var CROUCH_CAM_OFFSET: float = 1
var CROUCH_ANIM_TIME: float = 0.25
@onready var defaultPivotHeight = %CamPivot.position.y;

var crouched = false
var running = false
var walking = false

var is_alive = true 

@onready var hitbox: CollisionShape3D = %Hitbox
@onready var hitboxCrouched: CollisionShape3D = %HitboxCrouched
@onready var camera: Camera3D = %PlayerCamera
@onready var camPivot: Node3D = %CamPivot

@onready var activeWalkSound: AudioStreamPlayer3D = %WalkSound

func _ready() -> void:
	Game.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hitboxCrouched.disabled = true
	died.connect(func(): is_alive = false)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * get_speed()
		velocity.z = direction.z * get_speed()
		if !activeWalkSound.playing:
			activeWalkSound.play()
	else:
		velocity.x = move_toward(velocity.x, 0, get_speed())
		velocity.z = move_toward(velocity.z, 0, get_speed())
		activeWalkSound.stop()
		
	# View bobble
	if velocity.x != 0 || velocity.z != 0:
		view_bobble_progress += delta * VIEW_BOBBLE_SPEED * get_speed()
	
	%CamPivot.position.y = defaultPivotHeight + sin(view_bobble_progress) * VIEW_BOBBLE_AMOUNT - currentCrouchCamOffset
	
	# Handle sprinting
	if Input.is_action_pressed("sprint"):
		if activeWalkSound != %RunSound && !crouched:
			_set_active_walk_sound(%RunSound)
		if stamina > 0:
			if exhaustion <= 0 and crouched == false:
				stamina -= STAMINA_DRAIN * delta
		else:
			exhaustion = EXHAUSTION
	if !Input.is_action_pressed("sprint") || exhaustion > 0:
		stamina += STAMINA_GAIN * delta
		stamina = clamp(stamina, 0, 100)
		if exhaustion > 0:
			exhaustion -= delta
	
	# Handle crouching
	if Input.is_action_just_pressed("crouch"):
		if crouched == false:
			_set_active_walk_sound(%CrouchSound)
			hitbox.disabled = true
			hitboxCrouched.disabled = false
			crouched = true
			get_tree().create_tween().tween_property(self, "currentCrouchCamOffset", CROUCH_CAM_OFFSET, CROUCH_ANIM_TIME)
		else:
			_set_active_walk_sound(%WalkSound)
			hitbox.disabled = false
			hitboxCrouched.disabled = true
			crouched = false
			get_tree().create_tween().tween_property(self, "currentCrouchCamOffset", 0, CROUCH_ANIM_TIME)
	
	# Handle starting walk sound
	if !crouched && !Input.is_action_pressed("sprint") && activeWalkSound != %WalkSound:
		_set_active_walk_sound(%WalkSound)
	
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_motion(event)
	if event.is_action("interact"): _interact()
		
func _mouse_motion(event: InputEventMouseMotion) -> void:
	var motion: Vector2 = event.screen_relative
	self.rotation.y -= motion.x * SENSIBILITY
	camPivot.rotation.x -= motion.y * SENSIBILITY
	camPivot.rotation.x = clamp(camPivot.rotation.x, -PI/2, PI/2)
	
func _interact() -> void:
	var collisionObject: Object = %InteractionRaycast.get_collider()
	if collisionObject == null:
		return
	var collisionPoint: Vector3 = %InteractionRaycast.get_collision_point()
	if collisionPoint.distance_to(%InteractionRaycast.global_position) > INTERACTION_RANGE:
		return
	if collisionObject is not Interactable:
		return
	collisionObject.interacted.emit()
	
func get_speed():
	if Input.is_action_pressed("sprint") and stamina >= 0 and exhaustion <= 0 and crouched == false:
		return SPRINTSPEED
	if crouched == true:
		return CROUCHSPEED
	return SPEED

func blackout(time: float) -> void:
	%BlackoutRect.visible = true
	get_tree().create_timer(time).timeout.connect(func(): %BlackoutRect.visible = false)

func isMoving() -> bool:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward") != Vector2(0.0, 0.0)

func _set_active_walk_sound(streamPlayer: AudioStreamPlayer3D) -> void:
	%WalkSound.stop()
	%RunSound.stop()
	%CrouchSound.stop()
	self.activeWalkSound = streamPlayer
