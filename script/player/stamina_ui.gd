extends ProgressBar

func _process(_delta: float) -> void:
	value = Game.player.stamina
