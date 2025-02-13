extends RoomElement
class_name Door

signal opened

const CAMERA_TRANSITION_TIME: float = 0.1

var open: bool = false
var locked: bool = false
		

var nextRoom: Room = null

@onready var hitbox: StaticBody3D = %CollisionHitbox
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer
@onready var doorSoundPlayer: AudioStreamPlayer3D = %DoorSoundPlayer
@onready var lockedModel: Node3D = %LockedModel

func _ready() -> void:
	super._ready()
	%InteractionHitbox.interacted.connect(_on_interact, ConnectFlags.CONNECT_ONE_SHOT)
	opened.connect(_on_opened, ConnectFlags.CONNECT_ONE_SHOT)

func _on_opened() -> void:
	_set_start_monster_node()
	_set_end_monster_node()

	doorSoundPlayer.play()
	Game.room_opened.emit(nextRoom)

func _on_interact() -> void:
	if locked || open || !room.fullyGenerated:
		return
	opened.emit()
	open = true
	nextRoom.room_opened.emit()
	Game.player.set_crouched(false)
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
	animationPlayer.play("Door/open")
	animationPlayer.animation_finished.connect(func(_animation): _on_fully_opened(), ConnectFlags.CONNECT_ONE_SHOT)

func _on_fully_opened() -> void:
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
	animationPlayer.play("Door/open")
	animationPlayer.stop()
	open = false

func silent_lock(animate: bool = true) -> void:
	if open:
		if animate:
			close()
		else:
			instant_close()
	locked = true
