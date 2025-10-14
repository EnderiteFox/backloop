class_name MobManager
extends RefCounted

var entity_type: EntityManager.EntityType
var entity_category: EntityManager.EntityCategory
var mob_spawner: MobSpawner


func _init(p_entity_type: EntityManager.EntityType, p_entity_category: EntityManager.EntityCategory, p_mob_spawner: MobSpawner) -> void:
	self.entity_type = p_entity_type
	self.entity_category = p_entity_category
	self.mob_spawner = p_mob_spawner
	
	
## Registers the entity as active. Acts as a shortcut to the EntityManager
func register_active() -> void:
	Game.entity_manager.register_active(entity_type)
	
	
## Registers the entity as inactive. Acts as a shortcut to the EntityManager
func register_inactive() -> void:
	Game.entity_manager.register_inactive(entity_type)
