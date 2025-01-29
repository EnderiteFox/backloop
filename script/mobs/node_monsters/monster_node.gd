@tool
extends Marker3D
class_name MonsterNode

@export var nextNodes: Array[MonsterNode]

func getWholeGraph(visited: Array[MonsterNode]) -> Array[MonsterNode]:
	var recNextNodes: Array[MonsterNode]
	for node in nextNodes:
		recNextNodes.append(node.getWholeGraph(visited + [self]))
	var result: Array[MonsterNode] = [self] + recNextNodes
	for node in visited:
		result.erase(node)
	return result

func _physics_process(_delta: float) -> void:
	for node in get_children(true):
		node.queue_free()
	if Engine.is_editor_hint():
		_draw_lines()

func _draw_lines() -> void:
	
	for node in nextNodes:
		var material := ORMMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color.RED
		
		var mesh := ImmediateMesh.new()
		
		mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
		mesh.surface_add_vertex(to_local(self.global_position))
		mesh.surface_add_vertex(to_local(node.global_position))
		mesh.surface_end()
		
		var meshInstance := MeshInstance3D.new()
		meshInstance.mesh = mesh
		meshInstance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		self.add_child(meshInstance, false, Node.INTERNAL_MODE_BACK)
