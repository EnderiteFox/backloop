extends Node
## A class storing, loading and saving game settings.
## While getting settings can be done by directly accessing the variable,
## editing the variable directly won't correctly emit the setting_changed signal.
## Use [code]set_setting[/code] instead

enum Type {
	SENSIBILITY
}

signal setting_changed(type: Type, new_value: Variant)


var sensibility: float = 6


## Loads the settings from the save file.
## This will emit the [code]setting_changed[/code] signal for each loaded setting.
func load() -> void:
	pass
	
	
## Saves the settings to the save file
func save() -> void:
	pass
	
	
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
