extends Node
## A class storing, loading and saving game settings.
## While getting settings can be done by directly accessing the variable,
## editing the variable directly won't correctly emit the setting_changed signal.
## Use [code]set_setting[/code] instead

const SAVE_PATH: String = "user://settings.ini"

const SETTINGS_FILE_VERSION: int = 1

const MAIN_BUS_NAME: StringName = &"Master"
const MUSIC_BUS_NAME: StringName = &"Music"
const SOUNDS_BUS_NAME: StringName = &"Sounds"
const AMBIANCE_SOUNDS_BUS_NAME: StringName = &"Ambiance Sounds"

enum Type {
	SENSIBILITY,
	MAIN_VOLUME,
	MUSIC_VOLUME,
	SOUNDS_VOLUME,
	AMBIANCE_SOUNDS_VOLUME,
}

signal setting_changed(type: Type, new_value: Variant)


var sensibility: float = 6
var main_volume: float = 1
var music_volume: float = 1
var sounds_volume: float = 1
var ambiance_sounds_volume: float = 1


func _ready() -> void:
	self.setting_changed.connect(_on_setting_changed)
	load_settings()
	
	
func _notification(notif: int) -> void:
	if notif == NOTIFICATION_WM_CLOSE_REQUEST \
	or notif == NOTIFICATION_WM_GO_BACK_REQUEST \
	or notif == NOTIFICATION_APPLICATION_PAUSED:
		save_settings()


## Loads the settings from the save file.
## This will emit the [code]setting_changed[/code] signal for each loaded setting.
func load_settings() -> void:
	var file := ConfigFile.new()
	var first_load: bool = false
	var error: int = file.load(SAVE_PATH)
	if error:
		if error == Error.ERR_FILE_NOT_FOUND:
			Game.print_info("Settings file not found, using default settings")
			first_load = true
		else:
			Game.print_error("An error occured while loading settings: ", error_string(error))
			return
			
	var save_file_version: int
	if first_load:
		save_file_version = SETTINGS_FILE_VERSION
	else:
		save_file_version = file.get_value("Meta", "SETTINGS_FILE_VERSION", 0)
	if not save_file_version:
		Game.print_error("Could not read settings file version, errors may occur")
		
	for setting_type_name in Type.keys():
		set_setting(file.get_value("Settings", setting_type_name, get_setting(Type[setting_type_name])), Type[setting_type_name])
	
	
## Saves the settings to the save file
func save_settings() -> void:
	var file := ConfigFile.new()
	
	file.set_value("Meta", "SETTINGS_FILE_VERSION", SETTINGS_FILE_VERSION)
	
	for setting_type_name in Type.keys():
		file.set_value("Settings", setting_type_name, get_setting(Type[setting_type_name]))
	
	var error: int = file.save(SAVE_PATH)
	if error:
		Game.print_error("An error occured while saving settings: ", error_string(error))
		
	
	
## Returns the setting of the given type
func get_setting(type: Type) -> Variant:
	var varname: String = Type.find_key(type) as String
	varname = varname.to_lower()
	return self.get(varname)
	

## Sets a setting, while still doing proper type-checking
## This emits the [code]setting_changed[/code] signal
func set_setting(value: Variant, type: Type) -> void:
	var varname: String = Type.find_key(type) as String
	varname = varname.to_lower()
	var curr_setting_value: Variant = self.get(varname)
	
	var setting_type: int = typeof(curr_setting_value)
	var value_type: int = typeof(value)
	
	if setting_type != value_type:
		Game.print_error("Setting type and value type are different")
		return
		
	if setting_type == TYPE_OBJECT:
		if not (value as Object).is_class((curr_setting_value as Object).get_class()):
			Game.print_error("Setting and value have an incompatible class")
			return
			
	setting_changed.emit(type, value)
	self.set(varname, value)
	
	
func _on_setting_changed(type: Type, new_value: Variant) -> void:
	match type:
		Type.MAIN_VOLUME:
			var bus_idx: int = AudioServer.get_bus_index(MAIN_BUS_NAME)
			AudioServer.set_bus_volume_linear(bus_idx, new_value)
			
		Type.MUSIC_VOLUME:
			var bus_idx: int = AudioServer.get_bus_index(MUSIC_BUS_NAME)
			AudioServer.set_bus_volume_linear(bus_idx, new_value)
			
		Type.SOUNDS_VOLUME:
			var bus_idx: int = AudioServer.get_bus_index(SOUNDS_BUS_NAME)
			AudioServer.set_bus_volume_linear(bus_idx, new_value)
			
		Type.AMBIANCE_SOUNDS_VOLUME:
			var bus_idx: int = AudioServer.get_bus_index(AMBIANCE_SOUNDS_BUS_NAME)
			AudioServer.set_bus_volume_linear(bus_idx, new_value)

		_:
			pass
