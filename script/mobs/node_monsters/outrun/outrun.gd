extends NodeMonster
class_name Outrun

func _ready() -> void:
	super._ready()
	Game.outrun.isActive = true
	path_end_reached.connect(func(): Game.outrun.isActive = false)
