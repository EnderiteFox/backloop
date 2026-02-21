extends Node

@warning_ignore("unused_signal")
signal room_opened(room: Room)

@warning_ignore("unused_signal")
signal lights_flicker(duration: float)

signal time_changed(new_time: int)

#region Time Settings

const START_TIME: int = 6 * 60

const MIN_TIME_PROGRESS: int = 23
const MAX_TIME_PROGRESS: int = 33

#endregion

#region Node Groups

const WALLS_GROUP: StringName = "wall"

#endregion

var _internal_time: int = START_TIME

var player: Player

# Room handlers
var room_list := RoomList.new()

# Camera manager
var camera_manager: CameraManager

# Item manager
var item_manager := ItemManager.new()

# Monster managers
var theWatcher: TheWatcherManager

var nodeMonsters: NodeMonsterManager

## The current in-game time. Starts at START_TIME, and generally progresses when doors are open
var time: int:
	get:
		return _internal_time
	set(new_time):
		_internal_time = new_time
		time_changed.emit(new_time)

var room_generator: RoomGenerator

var entity_manager: EntityManager


func _ready() -> void:
	reset()	
	
	
func reset() -> void:
	if not room_opened.is_connected(_on_room_opened):
		room_opened.connect(_on_room_opened)
	time = START_TIME
	camera_manager = CameraManager.new()
	theWatcher = TheWatcherManager.new()
	nodeMonsters = NodeMonsterManager.new()
	room_generator = RoomGenerator.new()
	entity_manager = EntityManager.new()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		match(get_window().mode):
			Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_MAXIMIZED
			_:
				get_window().mode = Window.MODE_FULLSCREEN


func _on_room_opened(_room: Room) -> void:
	time += randi_range(MIN_TIME_PROGRESS, MAX_TIME_PROGRESS)
	
	
func print_message(...args: Array) -> void:
	if player != null and player.dev_console != null:
		player.dev_console.print_console.callv(args)
	else:
		print.callv(args)
	
	
func print_info(...args: Array) -> void:
	if player != null and player.dev_console != null:
		player.dev_console.print_info_console.callv(args)
	else:
		print.callv(args)
	
	
func print_warning(...args: Array) -> void:
	if player != null and player.dev_console != null:
		player.dev_console.print_warning_console.callv(args)
	else:
		push_warning.callv(args)
	
	
func print_error(...args: Array) -> void:
	if player != null and player.dev_console != null:
		player.dev_console.print_error_console.callv(args)
	else:
		push_error.callv(args)
