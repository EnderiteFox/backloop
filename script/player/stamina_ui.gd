extends ProgressBar

var exhausted: bool = false
var staminaFull: bool = true

const TWEEN_TIME: float = 0.5
const STAMINA_FULL_TRANSITION: float = 1
const STAMINA_NOT_FULL_TRANSITION: float = 0.5

var fadeOutTween: Tween = null
var fadeInTween: Tween = null

func _ready() -> void:
	self.self_modulate = Color.TRANSPARENT
	
func _process(_delta: float) -> void:
	value = Game.player.stamina
	
	if Game.player.exhaustion > 0 && !exhausted:
		var tween: Tween = self.create_tween()
		tween.tween_property(self, "modulate", Color.RED, TWEEN_TIME).from(Color.WHITE)
		tween.tween_callback(
			func(): %AnimationPlayer.play("exhausted")
		)
		exhausted = true
		
	elif exhausted && Game.player.exhaustion <= 0:
		var tween: Tween = self.create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, TWEEN_TIME).from(self.modulate)
		%AnimationPlayer.stop()
		exhausted = false
	
	if Game.player.stamina == 100 && !staminaFull:
		staminaFull = true
		if fadeInTween != null:
			fadeInTween.kill()
			fadeInTween = null
		fadeOutTween = self.create_tween()
		fadeOutTween.tween_property(
			self,
			"self_modulate",
			Color.TRANSPARENT,
			STAMINA_FULL_TRANSITION
		)
		fadeOutTween.tween_callback(func(): fadeOutTween = null)
		
	if Game.player.stamina < 100 && staminaFull && Game.player.exhaustion <= 0:
		staminaFull = false
		if fadeOutTween != null:
			fadeOutTween.kill()
			fadeOutTween = null
		fadeInTween = self.create_tween()
		fadeInTween.tween_property(
			self,
			"self_modulate",
			Color.WHITE,
			STAMINA_NOT_FULL_TRANSITION
		)
		fadeInTween.tween_callback(func(): fadeInTween = null)
