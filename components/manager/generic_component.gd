class_name GenericComponent
extends RefCounted


var component_id: StringName
var manager: ComponentManager


## Called every frame by the [code]ComponentManager[/code]
func tick(_delta: float) -> void:
	pass
	
	
## Makes sure that the component manager has been set
## Returns false in case of error
func ensure_manager_set() -> bool:
	if manager != null:
		return true
		
	Game.print_error("Manager was not set for component with id ", component_id)
	return false
