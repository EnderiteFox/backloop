extends ProgressBar

var exhausted: bool = false

const TWEEN_TIME: float = 0.5

func _process(_delta: float) -> void:
	value = Game.player.stamina
	if Game.player.exhaustion > 0 && !exhausted:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.RED, TWEEN_TIME).from(Color.WHITE)
		tween.tween_callback(
			func(): %AnimationPlayer.play("exhausted")
		)
		exhausted = true
	elif exhausted && Game.player.exhaustion <= 0:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, TWEEN_TIME).from(self.modulate)
		%AnimationPlayer.stop()
		exhausted = false
