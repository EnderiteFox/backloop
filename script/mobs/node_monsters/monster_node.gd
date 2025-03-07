@tool
class_name MonsterNode
extends Node3D

@export var nextNodes: Array[MonsterNode]
@export var nodeState: NodeState = NodeState.NORMAL
@export var fixPartialLinks: bool = true

const DEBUG_LINE_HEIGHT: float = 0.2

var graph: Array[MonsterNode]

var debugLines: MeshInstance3D = null

enum NodeState {
	NORMAL,
	ROOM_START,
	ROOM_END
}

@export_tool_button("Update path") var tool_update_path_action: Callable = _tool_update_path

func _tool_update_path() -> void:
	if fixPartialLinks:
		_fix_partial_links()
	graph = getWholeGraph()


func _ready() -> void:
	if Engine.is_editor_hint() && !nextNodes.is_empty():
		debugLines = _init_line()
	else:
		for node in get_children(true):
			if node.get_meta("is_internal", false):
				node.queue_free()
	if fixPartialLinks:
		_fix_partial_links()
	graph = getWholeGraph()


func _physics_process(_delta: float) -> void:
	_draw_lines()


func _fix_partial_links() -> void:
	for node in nextNodes:
		if self not in node.nextNodes:
			node.nextNodes.append(self)


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
	if debugLines == null || nextNodes.is_empty():
		return

	var material := ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.RED

	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

	for node in nextNodes:
		mesh.surface_add_vertex(to_local(self.global_position) + Vector3(0, DEBUG_LINE_HEIGHT, 0))
		mesh.surface_add_vertex(to_local(node.global_position) + Vector3(0, DEBUG_LINE_HEIGHT, 0))

	mesh.surface_end()

	debugLines.mesh = mesh


func getWholeGraph(visited: Array[MonsterNode] = []) -> Array[MonsterNode]:
	var recNextNodes: Array[MonsterNode]
	for node in nextNodes:
		if node in visited:
			continue
		var nextVisited: Array[MonsterNode] = Array(visited)
		nextVisited.append(self)
		recNextNodes.append_array(node.getWholeGraph(nextVisited))
	var tempResult: Array[MonsterNode] = recNextNodes
	tempResult.append(self)
	
	var result: Array[MonsterNode] = []
	for node in tempResult:
		if node not in result:
			result.append(node)
	
	return result
