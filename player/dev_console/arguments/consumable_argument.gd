class_name ConsumableArgument
extends EnumArgument


func _get_consumable_list() -> Array[String]:
	var consumable_list: Array[String]
	consumable_list.assign(Game.item_manager.consumable_infos.keys())
	return consumable_list
	
	
func accepts_token(token: String, preparse_mode: bool = false) -> bool:
	self.possible_values = _get_consumable_list()
	return super.accepts_token(token, preparse_mode)
	
	
func get_autocomplete_suggestions(partial_token: String) -> Array[String]:
	self.possible_values = _get_consumable_list()
	return super.get_autocomplete_suggestions(partial_token)
