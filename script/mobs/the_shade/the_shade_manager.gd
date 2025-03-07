class_name TheShadeManager
extends Resettable

const SPAWN_CHANCE: float = 0.2
const LENIENCE_TIME: float = 1.0
const ACTIVE_TIME: float = 2.0

const SPAWN_SAFE_DELAY: float = 1.5

const DESPAWN_BLACKOUT_TIME: float = 0.2

var isActive: bool = false

func reset() -> void:
	isActive = false
