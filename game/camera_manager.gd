class_name CameraManager
extends Resettable
## A manager that handles camera transitions
## Only one camera transition can happen at the same time
## If a transition is started while another was ongoing, the previous transition is interrupted and the new transition
## starts from the current transition camera position

## Emitted when a transition starts. Contains the camera transition object as a parameter.
signal transition_start(transition: CameraTransition)

var camera_scene: PackedScene = preload("uid://d4irak3k1xmaq")

var transition_camera: Camera3D
var transition_tween: Tween
var current_transition: CameraTransition = null


## Instantiates the transition camera if it has not been instantiated yet
func _prepare_camera() -> void:
	if transition_camera == null:
		transition_camera = camera_scene.instantiate()
		Game.player.get_tree().current_scene.add_child(transition_camera)
		
		
## Transfers all child nodes of a camera to another, while keeping their transform
func _transfer_camera_children(from: Camera3D, to: Camera3D) -> void:
	for child in from.get_children():
		if not child is Node3D:
			continue
		var node: Node3D = child as Node3D
		var transform: Transform3D = node.transform
		from.remove_child(node)
		to.add_child(node)
		node.transform = transform
		
		
## Makes a transition between two cameras, taking into account the nodes attached to the camera, like the player
## items.
## Returns a [code]CameraTransition[/code] object, that can be used to safely react to transition end and interruptions
## without having to take care of disconnecting signals
func make_transition(from: Camera3D, to: Camera3D, time: float) -> CameraTransition:
	_prepare_camera()
	if current_transition != null:
		transition_tween.kill()
		transition_tween = null
		current_transition.transition_interrupted.emit()
		current_transition.free()
		current_transition = null
		return make_transition(transition_camera, to, time)
		
	transition_camera.global_transform = from.global_transform
	_transfer_camera_children(from, transition_camera)
	transition_camera.make_current()
	
	transition_tween = transition_camera.create_tween()
	transition_tween.tween_property(
		transition_camera,
		"global_transform",
		to.global_transform,
		time
	).set_trans(Tween.TransitionType.TRANS_CUBIC)
	
	current_transition = CameraTransition.new()
	transition_tween.tween_callback(current_transition.transition_end.emit)
	transition_tween.tween_callback(_on_transition_end.bind(to))
	transition_start.emit(current_transition)
	
	return current_transition
	
	
func _on_transition_end(to: Camera3D) -> void:
	current_transition = null
	transition_tween = null
	_transfer_camera_children(transition_camera, to)
	to.make_current()
