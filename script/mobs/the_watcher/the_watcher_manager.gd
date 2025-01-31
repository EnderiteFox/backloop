extends RefCounted
class_name TheWatcherManager

const SPAWN_CHANCE: float = 0.2
const REACT_TIME: float = 1.5
const ACTIVE_DURATION: float = 2.0

const MIN_SPAWN_DELAY: float = 1.0
const MAX_SPAWN_DELAY: float = 2.0

const ENTER_BLACKOUT_TIME: float = 2.5
const WATCHER_ENTERED_TIME: float = 1.0

var isActive: bool = false
