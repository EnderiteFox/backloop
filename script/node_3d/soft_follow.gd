extends Node3D
## Makes a Node3D follow its starting position, relative to its parent
## This can be used eg. for a flashlight following the camera with a slight delay

const DEFAULT_FOLLOW_FACTOR: float = 10

@export_range(0.0, 1.0, 0.1, "or_greater") var follow_factor: float = DEFAULT_FOLLOW_FACTOR
@export var follow_position: bool = true
@export var follow_rotation: bool = true

@onready var position_offset: Vector3 = self.position
@onready var rotation_offset: Vector3 = self.rotation

func _ready() -> void:
	self.top_level = true


func _physics_process(delta: float) -> void:
	var node_parent: Node = self.get_parent()
	if !(node_parent is Node3D):
		printerr("Parent of SoftFollow node is not a Node3D")
		self.queue_free()
		return

	var parent: Node3D = node_parent as Node3D

	if follow_position:
		var target_position: Vector3 = position_offset
		target_position = target_position.rotated(Vector3.UP, parent.global_rotation.y)
		target_position = target_position.rotated(Vector3.FORWARD, parent.global_rotation.x)
		target_position = target_position.rotated(Vector3.RIGHT, parent.global_rotation.z)
		target_position += parent.global_position

		self.global_position = lerp(
			self.global_position,
			target_position,
			follow_factor * delta
		)

	if follow_rotation:
		self.global_rotation = Vector3(
			lerp_angle(self.global_rotation.x, parent.global_rotation.x + rotation_offset.x, follow_factor * delta),
			lerp_angle(self.global_rotation.y, parent.global_rotation.y + rotation_offset.y, follow_factor * delta),
			lerp_angle(self.global_rotation.z, parent.global_rotation.z + rotation_offset.z, follow_factor * delta)
		)
