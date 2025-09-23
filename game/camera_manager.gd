class_name CameraManager
extends Resettable
## A manager that handles camera transitions
## Only one camera transition can happen at the same time
## If a transition is started while another was ongoing, the previous transition is interrupted and the new transition
## starts from the current transition camera position

## Emitted when a transition starts
signal transition_start

## Emitted when a transition ends
signal transition_end

## Emitted when a transition is interrupted
## When waiting for a transition to end, and an interruption occurs, you should disconnect the transition_end signal
## to prevent reacting to the end of the new transition
signal transition_interrupted

var camera_scene: PackedScene = preload("uid://d4irak3k1xmaq")

var transition_camera: Camera3D
var transition_tween: Tween
var transitioning: bool = false


func _prepare_camera() -> void:
	if transition_camera == null:
		transition_camera = camera_scene.instantiate()
		Game.player.get_tree().current_scene.add_child(transition_camera)
		
		
func _transfer_camera_children(from: Camera3D, to: Camera3D) -> void:
	for child in from.get_children():
		if not child is Node3D:
			continue
		var node: Node3D = child as Node3D
		var transform: Transform3D = node.transform
		from.remove_child(node)
		to.add_child(node)
		node.transform = transform
		
		
func make_transition(from: Camera3D, to: Camera3D, time: float) -> void:
	_prepare_camera()
	if transitioning:
		transition_tween.kill()
		transition_tween = null
		transitioning = false
		transition_interrupted.emit()
		make_transition(transition_camera, to, time)
		return
		
	transition_camera.global_transform = from.global_transform
	_transfer_camera_children(from, transition_camera)
	transition_camera.make_current()
	transition_start.emit()
	
	transition_tween = transition_camera.create_tween()
	transition_tween.tween_property(
		transition_camera,
		"global_transform",
		to.global_transform,
		time
	).set_trans(Tween.TransitionType.TRANS_CUBIC)
	transition_tween.tween_callback(_on_transition_end.bind(to))
	transition_tween.tween_callback(transition_end.emit)
	
	
func _on_transition_end(to: Camera3D) -> void:
	transition_tween = null
	_transfer_camera_children(transition_camera, to)
	to.make_current()

