extends RoomElement

var theShadeScene: PackedScene = preload("res://scene/mobs/the_shade/the_shade.tscn")

func _ready() -> void:
	super._ready()
	room.room_opened.connect(_on_room_open)

func _physics_process(_delta: float) -> void:
	%Raycast.target_position = %Raycast.to_local(Game.player.camera.global_position)
	if %Raycast.get_collider() is Player:
		self.queue_free()
	

func _on_room_open() -> void:
	%Raycast.enabled = true
	get_tree().create_timer(Game.theShade.SPAWN_SAFE_DELAY).timeout.connect(func():
		_on_spawn_timer_end()
	)

func _on_spawn_timer_end() -> void:
	%Raycast.enabled = false
	if Game.theShade.isActive || !Game.player.is_alive:
		return
	if randf() > Game.theShade.SPAWN_CHANCE:
		return
	_spawn_the_shade()

func _spawn_the_shade() -> void:
	Game.theShade.isActive = true
	var theShade: TheShade = theShadeScene.instantiate()
	var globalRotation: Vector3 = self.global_rotation
	var globalPosition: Vector3 = self.global_position
	self.replace_by(theShade)
	theShade.global_rotation = globalRotation
	theShade.global_position = globalPosition
	self.queue_free()
