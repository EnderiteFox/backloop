class_name Outrun
extends NodeMonster

func _ready() -> void:
	super._ready()
	path_end_reached.connect(_on_path_end_reached)
	
	
func _on_path_end_reached() -> void:
	Game.entity_manager.outrun_manager.register_inactive()
