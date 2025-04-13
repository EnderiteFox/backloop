class_name Door
extends RoomElement

signal opened

const CAMERA_TRANSITION_TIME: float = 0.2

var open: bool = false
var state := State.NORMAL

var nextRoom: Room = null

@onready var hitbox: StaticBody3D = %CollisionHitbox
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer
@onready var doorSoundPlayer: AudioStreamPlayer3D = %DoorSoundPlayer
@onready var lockedModel: Node3D = %LockedModel
@onready var interaction_hitbox: Interactable = %InteractionHitbox

enum State {
	NORMAL,
	LOCKED,
	BLOCKED
}

func _ready() -> void:
	super._ready()
	interaction_hitbox.interacted.connect(_on_interact, ConnectFlags.CONNECT_ONE_SHOT)
	opened.connect(_on_opened, ConnectFlags.CONNECT_ONE_SHOT)
	opened.connect(
		func():
			for child in interaction_hitbox.get_children():
				if child is CollisionShape3D:
					child.disabled = true,
		ConnectFlags.CONNECT_ONE_SHOT
	)


func _on_opened() -> void:
	_set_start_monster_node()
	_set_end_monster_node()

	doorSoundPlayer.play()
	Game.room_opened.emit(nextRoom)


func _on_interact() -> void:
	# Don't open if door is locked
	if state == State.LOCKED || state == State.BLOCKED || open || !room.fullyGenerated:
		return

	# Update door state
	opened.emit()
	open = true
	nextRoom.room_opened.emit()

	# Uncrouch player
	Game.player.set_crouched(false)

	# Setup transition camera
	var camera: Camera3D = Camera3D.new()
	self.add_child(camera)
	camera.make_current()

	# Make the player's held items follow the transition camera
	var held_items_parent: Node = Game.player.held_items.get_parent()
	if held_items_parent != null:
		held_items_parent.remove_child(Game.player.held_items)

	camera.add_child(Game.player.held_items)

	# Animate transition camera
	var start_transform: Transform3D = Game.player.camera.global_transform
	var end_transform: Transform3D = %OpenCamera.global_transform
	var tween: Tween = self.create_tween()
	tween.tween_property(
		camera,
		"global_transform",
		end_transform,
		CAMERA_TRANSITION_TIME
	).from(start_transform)
	tween.tween_callback(
		func():
			_on_camera_tween_finished()
			camera.queue_free()
	)


func _on_camera_tween_finished() -> void:
	# Make the player's held items follow the animation camera
	var held_items_parent: Node = Game.player.held_items.get_parent()
	if held_items_parent != null:
		held_items_parent.remove_child(Game.player.held_items)

	%OpenCamera.add_child(Game.player.held_items)

	# Start opening animation
	%OpenCamera.make_current()
	animationPlayer.play("Door/open")
	animationPlayer.animation_finished.connect(func(_animation): _on_fully_opened(), ConnectFlags.CONNECT_ONE_SHOT)


func _on_fully_opened() -> void:
	# Make the player's held items follow the player's camera
	var held_items_parent: Node = Game.player.held_items.get_parent()
	if held_items_parent != null:
		held_items_parent.remove_child(Game.player.held_items)

	Game.player.camera.add_child(Game.player.held_items)

	Game.player.camera.make_current()
	Game.player.position = %PlayerTeleport.global_position
	Game.player.rotation = %PlayerTeleport.global_rotation
	Game.player.camPivot.rotation.x = %OpenCamera.global_rotation.x


func _set_start_monster_node() -> void:
	if nextRoom == null:
		return

	var graph: Array[MonsterNode] = nextRoom.anyMonsterNode.graph

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
	if room.anyMonsterNode.graph.is_empty():
		return

	for node in room.anyMonsterNode.graph:
		if node.nodeState == MonsterNode.NodeState.ROOM_END:
			node.nodeState = MonsterNode.NodeState.NORMAL

	var graph: Array[MonsterNode] = room.anyMonsterNode.graph
	graph.sort_custom(
		func(node1, node2):
			return node1.global_position.distance_squared_to(self.global_position) \
			< node2.global_position.distance_squared_to(self.global_position)
	)
	graph[0].nodeState = MonsterNode.NodeState.ROOM_END


func close() -> void:
	if !open:
		return
	animationPlayer.speed_scale = 2.0
	animationPlayer.play_backwards("Door/open")
	animationPlayer.animation_finished.connect(
		func(_animationName):
			open = false
			animationPlayer.speed_scale = 1.0
	)


func instant_close() -> void:
	if !open:
		return
	animationPlayer.play("Door/open")
	animationPlayer.stop()
	open = false


func silent_lock(animate: bool = true) -> void:
	if open:
		if animate:
			close()
		else:
			instant_close()
	state = State.LOCKED
	for child in interaction_hitbox.get_children():
		if child is CollisionShape3D:
			child.disabled = true


func make_blocked() -> void:
	instant_close()
	%BlockedModels.get_children().pick_random().visible = true
	state = State.BLOCKED
	for child in interaction_hitbox.get_children():
		if child is CollisionShape3D:
			child.disabled = true
