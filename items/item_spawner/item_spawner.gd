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

	var item: BaseItemInfo = loot_table.poll()
	if item == null:
		self.queue_free()
		return
		
	if item.on_ground_scene == null:
		Game.print_error("On ground scene for item ", item.id, " is null")
		self.queue_free()
		return
		
	var item_on_ground: BaseItemOnGround = item.on_ground_scene.instantiate()
	_place_item.call_deferred(item_on_ground)
	
	if item is ItemInfo:
		if not item_on_ground is ItemOnGround:
			Game.print_error("On ground scene for ItemInfo ", item.id, " was not an ItemOnGround")
		else:
			item_on_ground.item_info = item
	elif item is ConsumableInfo:
		if not item_on_ground is ConsumableOnGround:
			Game.print_error("On ground scene for ConsumableInfo ", item.id, " was not a ConsumableOnGround")
		else:
			item_on_ground.amount = randi_range(item.min_amount, item.max_amount)
			item_on_ground.consumable_info = item
	else:
		Game.print_error("Unknown type of info for item ", item.id)
		
		
func _place_item(item: Node3D) -> void:
	self.add_sibling(item)
	item.position = self.position
	item.scale = self.scale
	item.global_rotation = Vector3(0, randf_range(0.0, TAU), 0)
	self.queue_free()
