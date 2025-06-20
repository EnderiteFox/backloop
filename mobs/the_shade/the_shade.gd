class_name TheShade
extends CharacterBody3D

enum State {
	CHASING,
	MOVING,
	WAITING,
}

signal state_changed(state: State)

const MOVING_STATE_MOVE_SPEED: float = 2
const CHASING_STATE_MOVE_SPEED: float = 4

const LIGHT_DIM_RADIUS: float = 10.0
const LIGHT_DIM_DARKNESS_RADIUS: float = 4.5
const LIGHT_DIM_MIN_EFFECT: float = 1.0
const LIGHT_DIM_MAX_EFFECT: float = 0.0
const LIGHT_DIM_ACTIVATION_TIME: float = 1.0

@onready var navagent: NavigationAgent3D = %NavigationAgent3D
@onready var eye_raycast: RayCast3D = %EyeRaycast
@onready var front_raycast: RayCast3D = %FrontRaycast

@onready var light_dim_area: Area3D = %LightDimEffect
@onready var light_dim_area_shape: CollisionShape3D = %LightDimEffectShape
var light_dim_affected: Array[RoomLight]
var current_light_dim_max_effect: float = 0.0

var current_state := State.MOVING:
	set(new_state):
		if current_state != new_state:
			state_changed.emit(new_state)
		current_state = new_state


func _ready() -> void:
	navagent.velocity_computed.connect(_on_velocity_computed)
	
	assert(light_dim_area_shape.shape is SphereShape3D)
	(light_dim_area_shape.shape as SphereShape3D).radius = LIGHT_DIM_RADIUS
	light_dim_area.area_entered.connect(_on_light_enter_light_dim)
	light_dim_area.area_exited.connect(_on_light_leave_light_dim)


func _physics_process(_delta: float) -> void:
	eye_raycast.target_position = eye_raycast.to_local(Game.player.camera.global_position)
	front_raycast.target_position = front_raycast.to_local(Game.player.camera.global_position)
	navagent.set_target_position(Game.player.global_position)
	_update_state()
	_tick_current_state()
	_process_dim_lights()
	
	
#region Light dimming

func _process_dim_lights() -> void:
	for light in light_dim_affected:
		var distance: float = light.global_position.distance_to(self.light_dim_area_shape.global_position)
		light.energy = _get_light_energy_from_distance(distance)


func _on_light_enter_light_dim(area: Area3D) -> void:
	var parent: Node = area.get_parent()
	if parent is RoomLight and parent.breakHitbox == area:
		light_dim_affected.append(parent)
	
	
func _on_light_leave_light_dim(area: Area3D) -> void:
	var parent: Node = area.get_parent()
	if parent is RoomLight and parent.breakHitbox == area:
		light_dim_affected.erase(parent)
		parent.energy = 1.0
	
	
## The interpolation function used to determine the strength of the dim effect on nearby lights
func _get_light_energy_from_distance(distance: float) -> float:
	if current_state != State.CHASING:
		return 1.0
		
	if distance <= LIGHT_DIM_DARKNESS_RADIUS:
		return current_light_dim_max_effect
		
	return lerp(current_light_dim_max_effect, LIGHT_DIM_MIN_EFFECT, (distance - LIGHT_DIM_DARKNESS_RADIUS) / (LIGHT_DIM_RADIUS - LIGHT_DIM_DARKNESS_RADIUS))

#endregion


#region Movement

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

	
func _move_towards_player(speed: float) -> void:
	if NavigationServer3D.map_get_iteration_id(navagent.get_navigation_map()) == 0:
		return
	if navagent.is_navigation_finished():
		return
		
	var next_path_position: Vector3 = navagent.get_next_path_position() if not navagent.is_navigation_finished() else Game.player.global_position
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	if not is_zero_approx(self.global_position.cross(next_path_position).length()):
		self.look_at(next_path_position)
		self.rotation.x = 0
		self.rotation.z = 0
		
	if navagent.avoidance_enabled:
		navagent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
		
#endregion


#region Behavior

func _update_state() -> void:
	if current_state == State.CHASING:
		return

	var eye_sees_player: bool = eye_raycast.is_colliding() and eye_raycast.get_collider() is Player
	var front_sees_player: bool = front_raycast.is_colliding() and front_raycast.get_collider() is Player

	if eye_sees_player:
		current_state = State.CHASING
	elif front_sees_player:
		current_state = State.WAITING
	else:
		current_state = State.MOVING
		
		
func _on_state_change(state: State) -> void:
	if state == State.CHASING:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "current_light_dim_max_effect", LIGHT_DIM_MAX_EFFECT, LIGHT_DIM_ACTIVATION_TIME)
		
		
func _tick_current_state() -> void:
	match current_state:
		State.CHASING:
			_tick_chasing_state()
		State.MOVING:
			_tick_moving_state()
		State.WAITING:
			_tick_waiting_state()

	
func _tick_chasing_state() -> void:
	_move_towards_player(CHASING_STATE_MOVE_SPEED)
	

func _tick_moving_state() -> void:
	_move_towards_player(MOVING_STATE_MOVE_SPEED)
	
	
func _tick_waiting_state() -> void:
	if navagent.avoidance_enabled:
		navagent.set_velocity(Vector3.ZERO)

#endregion
