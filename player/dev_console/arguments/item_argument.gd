class_name ItemArgument
extends EnumArgument


func _get_item_list() -> Array[String]:
	var item_list: Array[String]
	item_list.assign(Game.item_manager.item_infos.keys())
	return item_list
	
	
func accepts_token(token: String, preparse_mode: bool = false) -> bool:
	self.possible_values = _get_item_list()
	return super.accepts_token(token, preparse_mode)
	
	
func get_autocomplete_suggestions(partial_token: String) -> Array[String]:
	self.possible_values = _get_item_list()
	return super.get_autocomplete_suggestions(partial_token)
