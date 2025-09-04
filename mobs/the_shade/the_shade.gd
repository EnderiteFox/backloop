class_name TheShade
extends CharacterBody3D

enum State {
	CHASING,
	MOVING,
	WAITING,
	FLASHED,
	CROSSING_DOOR,
}

signal state_changed(prev_state: State, state: State)

const MOVING_STATE_MOVE_SPEED: float = 2
const CHASING_STATE_MOVE_SPEED: float = 4
const DOOR_CROSSING_MOVE_SPEED: float = 2

const DOOR_CROSSING_ANIM_START_LERP_TIME: float = 0.2

const LIGHT_DIM_RADIUS: float = 10.0
const LIGHT_DIM_DARKNESS_RADIUS: float = 4.5
const LIGHT_DIM_MIN_EFFECT: float = 1.0
const LIGHT_DIM_MAX_EFFECT: float = 0.0
const LIGHT_DIM_ACTIVATION_TIME: float = 1.0

const ANIMATION_FLASHED: StringName = &"flashed"

@onready var navagent: NavigationAgent3D = %NavigationAgent3D
@onready var eye_raycast: RayCast3D = %EyeRaycast
@onready var front_raycast: RayCast3D = %FrontRaycast

@onready var door_cross_hitbox: Area3D = %DoorCrossHitbox
@onready var eye_flash_hitbox: Flashable = %EyeFlashHitbox

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var light_dim_area: Area3D = %LightDimEffect
@onready var light_dim_area_shape: CollisionShape3D = %LightDimEffectShape
var light_dim_affected: Array[RoomLight]
var current_light_dim_max_effect: float = 0.0

var crossing_door_end_pos: Vector3
var crossing_door_start_pos: Vector3
var crossing_door_is_start_door_lerp: bool = false
var crossing_door_tween: Tween = null

var prev_state := State.MOVING
var current_state := State.MOVING:
	set(new_state):
		if current_state != new_state:
			prev_state = current_state
			state_changed.emit(current_state, new_state)
		current_state = new_state


func _ready() -> void:
	navagent.velocity_computed.connect(_on_velocity_computed)
	
	assert(light_dim_area_shape.shape is SphereShape3D)
	(light_dim_area_shape.shape as SphereShape3D).radius = LIGHT_DIM_RADIUS
	light_dim_area.area_entered.connect(_on_light_enter_light_dim)
	light_dim_area.area_exited.connect(_on_light_leave_light_dim)
	
	door_cross_hitbox.area_entered.connect(_on_door_cross_area_entered)
	eye_flash_hitbox.flashed.connect(_on_flash)
	
	state_changed.connect(_on_state_change)


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
	if current_state != State.CHASING and (current_state != State.CROSSING_DOOR or prev_state != State.CHASING):
		return 1.0
		
	if distance <= LIGHT_DIM_DARKNESS_RADIUS:
		return current_light_dim_max_effect
		
	return lerp(
		current_light_dim_max_effect, 
		LIGHT_DIM_MIN_EFFECT, 
		(distance - LIGHT_DIM_DARKNESS_RADIUS) / (LIGHT_DIM_RADIUS - LIGHT_DIM_DARKNESS_RADIUS)
	)

#endregion


#region Movement

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if current_state in [State.WAITING, State.FLASHED]:
		return
	velocity = safe_velocity
	move_and_slide()

	
func _move_towards_player(speed: float) -> void:
	if NavigationServer3D.map_get_iteration_id(navagent.get_navigation_map()) == 0:
		return
		
	var next_path_position: Vector3 = navagent.get_next_path_position() if not navagent.is_navigation_finished() else Game.player.global_position
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	look_toward(next_path_position)
		
	if navagent.avoidance_enabled:
		navagent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
		
		
func _on_door_cross_area_entered(area: Area3D) -> void:
	if current_state == State.CROSSING_DOOR:
		return
		
	var node: Node = area.get_parent()
	if not node is Door:
		return
		
	var door: Door = node as Door
	
	if not door.open:
		return
	
	var target_position := Vector3.ZERO
	
	if area == door.door_cross_1:
		target_position = door.door_cross_2.global_position
	elif area == door.door_cross_2:
		target_position = door.door_cross_1.global_position
	else:
		return
	
	# Ensure we stay at the correct height
	target_position.y = self.global_position.y
	var origin_position: Vector3 = area.global_position
	origin_position.y = self.global_position.y
	
	crossing_door_is_start_door_lerp = true
	crossing_door_start_pos = origin_position
	crossing_door_end_pos = target_position
	current_state = State.CROSSING_DOOR
	
	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		origin_position,
		DOOR_CROSSING_ANIM_START_LERP_TIME
	)
	tween.tween_callback(func set_lerp_bool(): self.crossing_door_is_start_door_lerp = false)
	tween.tween_property(
		self,
		"global_position",
		target_position, 
		self.global_position.distance_to(target_position) / DOOR_CROSSING_MOVE_SPEED
	).from(origin_position)
	tween.tween_callback(func reset_prev_state(): self.current_state = self.prev_state)
	tween.tween_callback(func erase_tween(): self.crossing_door_tween = null)
	crossing_door_tween = tween
	
	
func look_toward(pos: Vector3) -> void:
	if self.global_position.is_equal_approx(pos):
		return
		
	if not is_zero_approx(self.global_position.cross(pos).length()):
		if not Vector3.UP.cross(pos - self.global_position).is_zero_approx():
			self.look_at(pos)
		self.rotation.x = 0
		self.rotation.z = 0
		
#endregion


#region Behavior

func _update_state() -> void:
	if current_state in [State.CHASING, State.FLASHED, State.CROSSING_DOOR]:
		return

	var eye_sees_player: bool = eye_raycast.is_colliding() and eye_raycast.get_collider() is Player
	var front_sees_player: bool = front_raycast.is_colliding() and front_raycast.get_collider() is Player

	if eye_sees_player:
		current_state = State.CHASING
	elif front_sees_player:
		current_state = State.WAITING
	else:
		current_state = State.MOVING
		
		
func _on_flash() -> void:
	if current_state == State.FLASHED:
		return
		
	if crossing_door_tween != null:
		crossing_door_tween.stop()
		crossing_door_tween = null
	
	current_state = State.FLASHED
	animation_player.play(ANIMATION_FLASHED)
	animation_player.animation_finished.connect(self.queue_free.unbind(1))
	

func _on_state_change(previous_state: State, state: State) -> void:
	if state == State.CHASING and previous_state != State.CROSSING_DOOR:
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
		State.CROSSING_DOOR:
			_tick_crossing_door_state()

	
func _tick_chasing_state() -> void:
	_move_towards_player(CHASING_STATE_MOVE_SPEED)
	

func _tick_moving_state() -> void:
	_move_towards_player(MOVING_STATE_MOVE_SPEED)
	
	
func _tick_crossing_door_state() -> void:
	if crossing_door_is_start_door_lerp:
		look_toward(crossing_door_start_pos)
	else:
		look_toward(crossing_door_end_pos)
	
	
func _tick_waiting_state() -> void:
	if navagent.avoidance_enabled:
		navagent.set_velocity(Vector3.ZERO)

#endregion
