extends Node3D
## Makes a Node3D follow its starting position, relative to its parent
## This can be used eg. for a flashlight following the camera with a slight delay

const DEFAULT_FOLLOW_FACTOR: float = 10

@onready var position_offset: Vector3 = self.position
@onready var rotation_offset: Vector3 = self.rotation

@export_range(0.0, 1.0, 0.1, "or_greater") var follow_factor: float = DEFAULT_FOLLOW_FACTOR
@export var follow_position: bool = true
@export var follow_rotation: bool = true

func _ready() -> void:
	self.top_level = true


func _physics_process(delta: float) -> void:
	var parent: Node = self.get_parent()
	if !(parent is Node3D):
		printerr("Parent of SoftFollow node is not a Node3D")
		self.queue_free()
		return

	if follow_position:
		self.global_position = lerp(
			self.global_position,
			parent.global_position + position_offset,
			follow_factor * delta
		)

	if follow_rotation:
		self.global_rotation = Vector3(
			lerp_angle(self.global_rotation.x, parent.global_rotation.x + rotation_offset.x, follow_factor * delta),
			lerp_angle(self.global_rotation.y, parent.global_rotation.y + rotation_offset.y, follow_factor * delta),
			lerp_angle(self.global_rotation.z, parent.global_rotation.z + rotation_offset.z, follow_factor * delta)
		)
