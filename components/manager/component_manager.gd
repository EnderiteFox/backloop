class_name ComponentManager
extends Node


@onready var components: Dictionary[StringName, GenericComponent] = {}


func _ready() -> void:
	for id: StringName in components:
		components[id].manager = self
		_verify_component(id, components[id])


func _process(delta: float) -> void:
	for component: GenericComponent in components.values():
		component.tick(delta)
		
		
static func get_from_node(node: Node) -> ComponentManager:
	for child: Node in node.get_children():
		if child is ComponentManager:
			return child as ComponentManager
			
	return null
	
	
func _verify_component(id: StringName, component: GenericComponent) -> void:
	if not ComponentId.is_known_id(id):
		Game.print_warning("Unknown component id: %s", id)
		
		var script: GDScript = component.get_script() as GDScript
		if ComponentId.get_component_type(id) != script:
			Game.print_error("Incorrect script for component %s: %s", id, script.get_global_name())
	
	
func register(id: StringName, component: GenericComponent) -> void:
	_verify_component(id, component)
	components[id] = component
	component.component_id = id
	component.manager = self
	
	
func has(id: StringName, script: GDScript) -> bool:
	if not components.has(id):
		return false
		
	var component: GenericComponent = components[id]
	return component.get_script() == script


func get_from_id(id: StringName, script: GDScript) -> GenericComponent:
	if not components.has(id):
		return null
		
	var component: GenericComponent = components[id]
	if component.get_script() != script:
		return null
		
	return component
