class_name ItemSpawner
extends Node3D


@onready var editor_mesh: Node3D = %EditorMesh


## If not null, overrides the [code]ItemManager[/code]'s loot table
@export var loot_table_override: LootTable = null


func _ready() -> void:
	if not Engine.is_editor_hint():
		editor_mesh.visible = false

	var loot_table: LootTable
	if loot_table_override != null:
		loot_table = loot_table_override
	else:
		loot_table = Game.item_manager.current_loot_table

	var item: Array = loot_table.poll()
	if item.is_empty():
		self.queue_free()
		return
		
	if not item[0] is BaseItemInfo:
		Game.print_error("Loot table returned incorrect data for ", item[0].id, " (1 element, not ItemInfo)")
		return
	if item[0].on_ground_scene == null:
		Game.print_error("On ground scene for item ", item[0].id, " is null")
		self.queue_free()
		return
		
	var item_on_ground: BaseItemOnGround = item[0].on_ground_scene.instantiate()
	_place_item.call_deferred(item_on_ground)
	
	if item[0] is ItemInfo:
		if not item_on_ground is ItemOnGround:
			Game.print_error("On ground scene for ItemInfo ", item[0].id, " was not an ItemOnGround")
		else:
			item_on_ground.item_info = item[0]
	elif item[0] is ConsumableInfo:
		if item.size() < 2:
			Game.print_error("Loot table didn't return an item count for ", item[0].id)
			return
		if not item[1] is int:
			Game.print_error("Item count for ", item[0].id, " was not an int")
			return
		if not item_on_ground is ConsumableOnGround:
			Game.print_error("On ground scene for ConsumableInfo ", item[0].id, " was not a ConsumableOnGround")
		else:
			item_on_ground.amount = item[1]
			item_on_ground.consumable_info = item[0]
	else:
		Game.print_error("Unknown type of info for item ", item[0].id)
		
		
func _place_item(item: Node3D) -> void:
	self.add_sibling(item)
	item.position = self.position
	item.scale = self.scale
	item.global_rotation = Vector3(0, randf_range(0.0, TAU), 0)
	self.queue_free()
