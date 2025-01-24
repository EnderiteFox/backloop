extends CharacterBody3D
class_name Player

const SPEED = 2.0
const SENSIBILITY: float = 0.008

const VIEW_BOBBLE_AMOUNT: float = 0.08
const VIEW_BOBBLE_SPEED = 3.5
var view_bobble_progress: float = 0.0

const INTERACTION_RANGE: float = 2.0

@onready var camera: Camera3D = %PlayerCamera
@onready var camPivot: Node3D = %CamPivot

func _ready() -> void:
	Game.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# View bobble
	if velocity.x != 0 || velocity.z != 0:
		view_bobble_progress += delta * VIEW_BOBBLE_SPEED * SPEED
	
	%PlayerCamera.position.y = sin(view_bobble_progress) * VIEW_BOBBLE_AMOUNT

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
