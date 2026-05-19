class_name ComponentId


const LightEnergy: StringName = &"light_energy"


static var _component_classes: Dictionary[StringName, GDScript] = {
	LightEnergy: MultiplierComponent
}


static func is_known_id(id: StringName) -> bool:
	return _component_classes.has(id)
	
	
static func get_component_type(id: StringName) -> GDScript:
	return _component_classes[id]
