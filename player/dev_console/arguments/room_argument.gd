class_name RoomArgument
extends EnumArgument


func _get_room_list() -> Array[String]:
	var room_list: Array[String]
	room_list.assign(Game.room_list.room_infos.keys())
	return room_list

	
func accepts_token(token: String, preparse_mode: bool = false) -> bool:
	self.possible_values = _get_room_list()
	return super.accepts_token(token, preparse_mode)
	
	
func get_autocomplete_suggestions(partial_token: String) -> Array[String]:
	self.possible_values = _get_room_list()
	return super.get_autocomplete_suggestions(partial_token)
