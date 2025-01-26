extends RoomElement

var theShadeScene: PackedScene = preload("res://scene/mobs/the_shade/the_shade.tscn")

const ROOM_OPENED_SPAWN_DELAY: float = 0.5

func _ready() -> void:
	super._ready()
	room.room_opened.connect(_on_room_open)

func _on_room_open() -> void:
	if room.previousRoom != null:
		for door in room.previousRoom.doors:
			%Raycast.add_exception(door.hitbox)
	%Raycast.target_position = %Raycast.to_local(Game.player.camera.global_position)
	get_tree().create_timer(ROOM_OPENED_SPAWN_DELAY).timeout.connect(func():
		if %Raycast.get_collider() is Player:
			return
		%Raycast.enabled = false
		if Game.theShade.isActive || !Game.player.is_alive:
			return
		if randf() > Game.theShade.SPAWN_CHANCE:
			return
		_spawn_the_shade()
	)

func _spawn_the_shade() -> void:
	Game.theShade.isActive = true
	var theShade: TheShade = theShadeScene.instantiate()
	self.add_child(theShade)
