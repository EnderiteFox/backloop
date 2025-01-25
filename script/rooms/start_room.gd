extends Room

func _ready() -> void:
	super._ready()
	Game.roomGenerator.fully_generate.call_deferred(self)
