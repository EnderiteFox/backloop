class_name Door
extends RoomElement

signal opened
signal closed

const CAMERA_TRANSITION_TIME: float = 0.35
const CAMERA_END_TRANSITION_TIME: float = 0.2


var nextRoom: Room = null

@onready var hitbox: StaticBody3D = %CollisionHitbox
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer
@onready var doorSoundPlayer: AudioStreamPlayer3D = %DoorSoundPlayer
@onready var lockedModel: Node3D = %LockedModel
@onready var interaction_hitbox: Interactable = %InteractionHitbox
@onready var open_camera: CinematicCamera = %OpenCamera

@onready var door_cross_1: Area3D = %DoorCross1
@onready var door_cross_2: Area3D = %DoorCross2

@onready var open: bool = false: set = _set_open
@onready var state: State = State.NORMAL: set = _set_state
@onready var can_interact: bool = true: set = _set_can_interact

enum State {
	NORMAL,
	LOCKED,
	BLOCKED
}

func _ready() -> void:
	super._ready()
	interaction_hitbox.interacted.connect(_on_interact)
	opened.connect(_on_opened)


func _on_opened() -> void:
	_set_start_monster_node()
	_set_end_monster_node()

	doorSoundPlayer.play()
	Game.room_opened.emit(nextRoom)
	nextRoom.room_opened.emit()
	can_interact = false
	
	
func _can_open() -> bool:
	return not open and state == State.NORMAL and room.fullyGenerated
	
	
func _set_open(new_open: bool) -> void:
	if not open and new_open:
		opened.emit()
	if open and not new_open:
		closed.emit()
	open = new_open
	
	
func _set_can_interact(new_can_interact: bool) -> void:
	if can_interact == new_can_interact:
		return
	
	for child in interaction_hitbox.get_children():
		if child is CollisionShape3D:
			child.disabled = not new_can_interact
		
	can_interact = new_can_interact
	
	
func _set_state(new_state: State) -> void:
	# Can't interact anymore
	if new_state != State.NORMAL and state == State.NORMAL:
		can_interact = false
		
	# Can now interact
	if new_state == State.NORMAL and state != State.NORMAL and not open:
		can_interact = true
	
	# When blocking the door
	if new_state == State.BLOCKED and state != State.BLOCKED:
		instant_close()
		%BlockedModels.get_children().pick_random().visible = true
		
	# When unblocking the door
	if new_state != State.BLOCKED and state == State.BLOCKED:
		for child in %BlockedModels.get_children():
			child.visible = false
		
	# If the state closes the door
	if state == State.NORMAL and new_state != State.NORMAL and open:
		instant_close()
		
	state = new_state


func _on_interact() -> void:
	# Don't open if door is locked
	if !_can_open():
		return

	# Update door state
	open = true

	# Uncrouch player
	Game.player.set_crouched(false)
	Game.player.can_move = false
	
	# Setup camera transition
	var transition: CameraTransition = Game.camera_manager.make_transition(
		Game.player.camera,
		open_camera.camera,
		CAMERA_TRANSITION_TIME
	)
	transition.transition_end.connect(_on_camera_transition_end)


func _on_camera_transition_end() -> void:
	# Start opening animation
	animationPlayer.play("Door/open")
	animationPlayer.animation_finished.connect(func(_animation): _on_fully_opened(), ConnectFlags.CONNECT_ONE_SHOT)
	
	
func _on_end_camera_transition_end() -> void:
	Game.player.can_move = true


func _on_fully_opened() -> void:
	Game.player.position = %PlayerTeleport.global_position
	Game.player.rotation = %PlayerTeleport.global_rotation
	Game.player.camPivot.rotation.x = %OpenCamera.global_rotation.x
	
	var transition: CameraTransition = Game.camera_manager.make_transition(
		open_camera.camera,
		Game.player.camera,
		CAMERA_END_TRANSITION_TIME
	)
	transition.transition_end.connect(_on_end_camera_transition_end)
	
	if nextRoom != null:
		nextRoom.fully_opened.emit()


func _set_start_monster_node() -> void:
	if nextRoom == null:
		return

	var graph: Array[MonsterNode] = nextRoom.monster_nodes

	if graph.is_empty():
		return

	if graph.any(func(node): return node.nodeState == MonsterNode.NodeState.ROOM_START):
		return

	graph.sort_custom(
		func(node1, node2):
			return node1.global_position.distance_squared_to(self.global_position) \
			< node2.global_position.distance_squared_to(self.global_position)
	)
	graph[0].nodeState = MonsterNode.NodeState.ROOM_START


func _set_end_monster_node() -> void:
	if room.monster_nodes.is_empty():
		return

	for node in room.monster_nodes:
		if node.nodeState == MonsterNode.NodeState.ROOM_END:
			node.nodeState = MonsterNode.NodeState.NORMAL

	var graph: Array[MonsterNode] = room.monster_nodes
	graph.sort_custom(
		func(node1, node2):
			return node1.global_position.distance_squared_to(self.global_position) \
			< node2.global_position.distance_squared_to(self.global_position)
	)
	graph[0].nodeState = MonsterNode.NodeState.ROOM_END


func close() -> void:
	if not open:
		return
		
	animationPlayer.speed_scale = 2.0
	animationPlayer.play_backwards("Door/open")
	await animationPlayer.animation_finished
	open = false
	can_interact = true
	animationPlayer.speed_scale = 1.0


func instant_close() -> void:
	if not open:
		return
		
	animationPlayer.play("Door/open")
	animationPlayer.stop()
	open = false


func silent_lock(animate: bool = true) -> void:
	if open:
		if animate:
			await close()
		else:
			instant_close()
	state = State.LOCKED
	for child in interaction_hitbox.get_children():
		if child is CollisionShape3D:
			child.disabled = true
