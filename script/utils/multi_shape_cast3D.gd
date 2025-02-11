extends ShapeCast3D
class_name MultiShapeCast3D

func is_any_shape_colliding() -> bool:
	self.enabled = true
	var children: Array[Node] = get_children()
	var shapes: Array[CollisionShape3D] = []
	for node in children:
		if node is CollisionShape3D:
			shapes.append(node)

	for childShape in shapes:
		self.shape = childShape.shape
		self.force_shapecast_update()
		if self.get_collision_count() > 0:
			self.enabled = false
			return true

	self.enabled = false
	return false

