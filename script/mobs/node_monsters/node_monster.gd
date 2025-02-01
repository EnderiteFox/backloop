extends Node3D
class_name NodeMonster

signal path_end_reached

var path: PackedVector3Array
var currentPathPoint: int = 0

var moving: bool = false


## If true, deletes the node monster when it reaches the end of its path
@export var freeOnPathEnd: bool = true

## The amount of time that the lights will flicker when this monster spawns
@export var lightFlickerTime: float = 2

@export_range(0, 100, 0.1, "or_greater", "suffix:m/s") var moveSpeed: float = 1.0

func setup(monsterPath: PackedVector3Array, timeBeforeMove: float) -> void:
	if monsterPath.is_empty():
		printerr("Node monster can't follow empty path")
		self.queue_free()
		return

## Activates the node monster, defining its path, teleporting it to the first path node, and setting it to move
func activate(monsterPath: PackedVector3Array) -> void:
	if monsterPath.is_empty():
		printerr("Node monster can't follow empty path")
		self.queue_free()
		return

	self.path = monsterPath
	self.global_position = self.path[0]
	self.currentPathPoint = 1
	self.moving = true

	Game.lights_flicker.emit(lightFlickerTime)



func _physics_process(delta: float) -> void:
	if !moving:
		return

	if currentPathPoint >= path.size():
		path_end_reached.emit()
		if freeOnPathEnd:
			self.queue_free()
		return

	if self.global_position.distance_to(path[currentPathPoint]) < moveSpeed * delta:
		self.global_position = path[currentPathPoint]
		currentPathPoint += 1
	else:
		self.global_position += self.global_position.direction_to(path[currentPathPoint]) * moveSpeed * delta

