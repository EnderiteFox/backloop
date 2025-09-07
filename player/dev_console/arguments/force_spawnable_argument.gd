class_name ForceSpawnableArgument
extends EnumArgument


func _get_force_spawnable_ids() -> Array[String]:
	var entity_ids: Array[String] = []
	
	for entity: EntityManager.EntityType in EntityManager.EntityType.values():
		var mob_manager: MobManager = Game.entity_manager.get_manager(entity)
		if mob_manager == null:
			continue
		
		var mob_spawner: MobSpawner = mob_manager.mob_spawner
		if not mob_spawner.supports_force_spawn:
			continue
		
		entity_ids.append(Game.entity_manager.get_entity_id(entity))
			
	return entity_ids
	

func accepts_token(token: String, preparse_mode: bool = false) -> bool:
	self.possible_values = _get_force_spawnable_ids()
	return super.accepts_token(token, preparse_mode)


func get_autocomplete_suggestions(partial_token: String) -> Array[String]:
	self.possible_values = _get_force_spawnable_ids()
	return super.get_autocomplete_suggestions(partial_token)
