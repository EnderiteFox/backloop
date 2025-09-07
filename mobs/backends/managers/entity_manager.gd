class_name EntityManager
extends Resettable

enum EntityType {
	THE_SHADE,
	THE_WATCHER,
	OUTRUN
}
	
enum EntityCategory {
	RUSHER,
	AMBIENT
}

const entity_category_exclusions: Dictionary[EntityCategory, Array] = {
	EntityCategory.RUSHER: [EntityCategory.AMBIENT],
	EntityCategory.AMBIENT: [EntityCategory.RUSHER],
}

var entity_ids: Dictionary[EntityType, String]

var active_entity_categories: Dictionary[EntityCategory, int]
var active_entities: Dictionary[EntityType, int]

#region Mob Managers

var the_shade_manager := TheShadeManager.new()

var mob_managers: Dictionary[EntityType, MobManager] = {
	EntityType.THE_SHADE: the_shade_manager
}

#endregion


func _init() -> void:
	for category: EntityCategory in EntityCategory.values():
		active_entity_categories[category] = 0
	for entity_type: EntityType in EntityType.values():
		active_entities[entity_type] = 0
		
	for entity_enum_name: String in EntityType.keys():
		entity_ids[EntityType[entity_enum_name]] = entity_enum_name.to_lower()
		
		
## Returns the MobManager corresponding to the entity
## Returns [code]null[/code] if the entity has no registered manager
func get_manager(entity: EntityType) -> MobManager:
	if not mob_managers.has(entity):
		return null
	return mob_managers[entity]
	
	
## Registers an entity as active, incrementing their counters
func register_active(entity: EntityType) -> void:
	active_entities[entity] += 1
	active_entity_categories[get_manager(entity).entity_category] += 1
	
	
## Registers an entity as inactive, decrementing their counters
func register_inactive(entity: EntityType) -> void:
	active_entities[entity] -= 1
	active_entity_categories[get_manager(entity).entity_category] -= 1
	
	
## Returns the count of active instances of the given entity
func get_entity_active(entity: EntityType) -> int:
	return active_entities[entity]


## Returns the count of active instances of entities of the given category
func get_category_active(entity_category: EntityCategory) -> int:
	return active_entity_categories[entity_category]
	
	
## Returns the id for the entity
## The id is a human-readable representation of the EntityType
func get_entity_id(entity: EntityType) -> String:
	return entity_ids.get_or_add(entity, "unknown")
	
	
## Returns the EntityType from its id
func get_entity_from_id(entity_id: String) -> EntityType:
	return entity_ids.find_key(entity_id)
	
	
## Returns [code]true[/code] if any currently active entity is conflicting with the given entity category
func has_conflicted_active(entity_category: EntityCategory) -> bool:
	return entity_category_exclusions[entity_category].any(get_category_active)
