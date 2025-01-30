@tool
extends Node3D
class_name MonsterNode

@export var nextNodes: Array[MonsterNode]
@export var nodeState: NodeState = NodeState.NORMAL
var graph: Array[MonsterNode]

var debugLines: MeshInstance3D = null

enum NodeState {
	NORMAL,
	ROOM_START,
	ROOM_END
}

func _ready() -> void:
	if Engine.is_editor_hint():
		debugLines = _init_line()
	else:
		for node in get_children(true):
			if node.get_meta("is_internal", false):
				node.queue_free()
	graph = getWholeGraph()


func getWholeGraph(visited: Array[MonsterNode] = []) -> Array[MonsterNode]:
	var recNextNodes: Array[MonsterNode]
	for node in nextNodes:
		if node in visited:
			continue
		var nextVisited: Array[MonsterNode] = Array(visited)
		nextVisited.append(self)
		recNextNodes.append_array(node.getWholeGraph(nextVisited))
	var result: Array[MonsterNode] = recNextNodes
	result.append(self)
	return result

func _physics_process(_delta: float) -> void:
	_draw_lines()

func _init_line() -> MeshInstance3D:
	for node in get_children(true):
			if node.get_meta("is_internal", false):
				node.queue_free()
	
	var material := ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.RED
	
	var meshInstance := MeshInstance3D.new()
	meshInstance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	meshInstance.set_meta("is_internal", true)
	
	self.add_child(meshInstance, false, Node.INTERNAL_MODE_BACK)
	return meshInstance
	

func _draw_lines() -> void:
	if debugLines == null:
		return
		
	var material := ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.RED
	
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	for node in nextNodes:
		if self in node.nextNodes:
			mesh.surface_add_vertex(to_local(self.global_position))
			mesh.surface_add_vertex(to_local(node.global_position))

	mesh.surface_end()
	
	debugLines.mesh = mesh
