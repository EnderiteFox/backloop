class_name MobSpawner
extends Resettable


var entity_type: EntityManager.EntityType
var entity_category: EntityManager.EntityCategory

## If true, the spawning of the mob can be instantly forced
var supports_force_spawn: bool

## The maximum amount of this entity that can be active before spawning is disabled
var max_active_count: int
## The maximum amount of this entity category that can be active before spawning is disabled
var max_category_active_count: int


func _init(
	p_entity_type: EntityManager.EntityType,
	p_entity_category: EntityManager.EntityCategory,
	p_supports_force_spawn: bool,
	p_max_active_count: int = 1,
	p_max_category_active_count: int = 1
) -> void:
	self.entity_type = p_entity_type
	self.entity_category = p_entity_category
	self.supports_force_spawn = p_supports_force_spawn
	self.max_active_count = p_max_active_count
	self.max_category_active_count = p_max_category_active_count
	
	
## Forces the spawning of the mob
## Can only be called if [code]supports_force_spawn[/code] is true
## Otherwise, an error will be pushed
## Returns [code]true[/code] if the mob was spawned successfully
func force_spawn() -> bool:
	if not supports_force_spawn:
		Game.print_error("Tried to force spawn with a MobSpawner that doesn't support force_spawn")
		return false
	return true
	

## Returns [code]true[/code] if this entity is excluded because the maximum amount of mob is active,
## or if a mob from an incompatible category is active
func is_excluded() -> bool:
	return Game.entity_manager.get_entity_active(entity_type) >= max_active_count \
		or Game.entity_manager.get_category_active(entity_category) >= max_category_active_count \
		or Game.entity_manager.has_conflicted_active(entity_category)
