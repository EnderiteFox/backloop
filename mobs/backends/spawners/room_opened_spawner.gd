class_name RoomOpenedSpawner
extends MobSpawner

## Emitted when the entity is selected to spawn
signal spawn(room: Room)

## The starting spawn chance when opening a room
var base_spawn_chance: float = 0.0

## The current spawn chance. Changes based on spawn success or failure
var current_spawn_chance: float = 0.0: set = _set_current_spawn_chance

## How much the spawn chance changes when the spawn fails
## Used to prevent situations where a mob is unlucky and only spawns in rooms not allowing it to spawn, by increasing
## the spawn chance in such situations
var spawn_fail_chance_bonus: float = 0.0

## The amount of rooms that this entity can't spawn after spawning
var room_count_cooldown: int = 0

## The current amount of rooms before this entity can spawn again
var current_room_cooldown: int = 0


func _init(
	p_entity_type: EntityManager.EntityType,
	p_entity_category: EntityManager.EntityCategory,
	p_supports_force_spawn: bool,
	p_base_spawn_chance: float,
	p_spawn_fail_chance_bonus: float,
	p_room_count_cooldown: int = 0,
	p_max_active_count: int = 1,
	p_max_category_active_count: int = 1
) -> void:
	super._init(
		p_entity_type,
		p_entity_category,
		p_supports_force_spawn,
		p_max_active_count,
		p_max_category_active_count
	)
	self.base_spawn_chance = clamp(p_base_spawn_chance, 0.0, 1.0)
	self.current_spawn_chance = self.base_spawn_chance
	self.spawn_fail_chance_bonus = clamp(p_spawn_fail_chance_bonus, 0.0, 1.0)
	self.room_count_cooldown = p_room_count_cooldown
	self.current_room_cooldown = self.room_count_cooldown
	
	Game.room_opened.connect(self._on_room_opened)
	
	
func _set_current_spawn_chance(new_current_spawn_chance) -> void:
	current_spawn_chance = clamp(new_current_spawn_chance, 0.0, 1.0)
	
	
func _on_room_opened(room: Room) -> void:
	if current_room_cooldown > 0:
		current_room_cooldown -= 1
		return
	
	if randf() > current_spawn_chance:
		return
		
	if is_excluded():
		return
		
	spawn.emit(room)
	
	
## Must be called if the spawn failed
## Increases the current spawn chance by the spawn fail bonus
func spawn_failed() -> void:
	current_spawn_chance += spawn_fail_chance_bonus
	
	
## Must be called if the spawn succeeds
## Resets the current spawn chance to the base spawn chance
## Also resets the room cooldown
func spawn_succeeded() -> void:
	current_spawn_chance = base_spawn_chance
	current_room_cooldown = room_count_cooldown
	
	
func force_spawn() -> bool:
	if not super.force_spawn():
		return false
		
	spawn.emit(Game.room_generator.last_room_opened)
	return true
