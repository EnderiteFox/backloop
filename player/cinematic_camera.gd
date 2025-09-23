class_name CinematicCamera
extends Node3D

@onready var camera: Camera3D = %Camera

var center_rotation: Vector3 = Vector3.ZERO
var target_rotation: Vector3 = center_rotation

## The maximum view angle in each direction, in degrees
@export var view_angle: Vector2 = Vector2(30, 30)
## The camera speed to reach the target angle
@export var smooth_speed: float = 4.0
## The sensibility of the camera
@export var sensibility: float = 2.0


func _process(delta: float) -> void:
	if not camera.current:
		return
		
	camera.rotation.x = lerp_angle(camera.rotation.x, target_rotation.x, delta * smooth_speed)
	camera.rotation.y = lerp_angle(camera.rotation.y, target_rotation.y, delta * smooth_speed)
	
	
func _input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion or not camera.current:
		return
	
	var mouse_event: InputEventMouseMotion = event
	var mouse_relative: Vector2 = mouse_event.screen_relative
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	var relative_factor: Vector2 = mouse_relative / screen_size
		
	target_rotation.x = clamp(target_rotation.x + -relative_factor.y * sensibility, center_rotation.x - deg_to_rad(view_angle.x), center_rotation.x + deg_to_rad(view_angle.x))
	target_rotation.y = clamp(target_rotation.y + -relative_factor.x * sensibility, center_rotation.y - deg_to_rad(view_angle.y), center_rotation.y + deg_to_rad(view_angle.y))
	
