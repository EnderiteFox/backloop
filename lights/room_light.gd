class_name RoomLight
extends RoomElement

@export var lights: Array[Light3D]
@export var model: Node3D

var default_energies: Dictionary[Light3D, float]
var default_material_emissions: Dictionary[BaseMaterial3D, float]
var default_material_colors: Dictionary[BaseMaterial3D, Color]

var component_manager: ComponentManager
var light_energy_component: LightEnergyComponent

func _ready() -> void:
	super._ready()
	
	component_manager = ComponentManager.new()
	self.add_child(component_manager)
	
	light_energy_component = LightEnergyComponent.new()
	component_manager.register(ComponentId.LightEnergy, light_energy_component)
	
	# React to light changes
	light_energy_component.multiplier_changed.connect(_on_light_energy_change)
	light_energy_component.on_break.connect(_on_light_break)
	
	# Store default light values
	_get_default_emissions(model)
	for light in lights:
		default_energies[light] = light.light_energy
		
		
func _on_light_energy_change() -> void:
	var mult: float = light_energy_component.get_effect()
	
	for light in lights:
		light.light_energy = default_energies[light] * mult
		
	for material: StandardMaterial3D in default_material_emissions.keys():
		material.emission_energy_multiplier = default_material_emissions[material] * mult
		material.emission = default_material_colors[material].darkened(1.0 - mult)


func _on_light_break() -> void:
	for light in lights:
		light.visible = false
	lights.clear()
	
	
func _get_default_emissions(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh: Mesh = node.get_mesh()
		var surface_count: int = mesh.get_surface_count()
		for i in range(surface_count):
			var material: Material = node.get_active_material(i)
			if material is BaseMaterial3D:
				var standard_material: BaseMaterial3D = material as BaseMaterial3D
				default_material_emissions[standard_material] = standard_material.emission_energy_multiplier
				default_material_colors[standard_material] = standard_material.emission
				standard_material.emission_operator = BaseMaterial3D.EMISSION_OP_MULTIPLY
				
	for child: Node in node.get_children():
		_get_default_emissions(child)
