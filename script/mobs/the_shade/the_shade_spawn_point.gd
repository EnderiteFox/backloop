extends RoomElement

var theShadeScene: PackedScene = preload("res://scene/mobs/the_shade/the_shade.tscn")

var sawPlayer: bool = false

func _ready() -> void:
	super._ready()
	room.room_opened.connect(_on_room_open)

func _physics_process(_delta: float) -> void:
	%Raycast.target_position = %Raycast.to_local(Game.player.camera.global_position)
	sawPlayer = sawPlayer || %Raycast.get_collider() is Player
	

func _on_room_open() -> void:
	%Raycast.enabled = true
	get_tree().create_timer(Game.theShade.SPAWN_SAFE_DELAY).timeout.connect(func():
		_on_spawn_timer_end()
	)

func _on_spawn_timer_end() -> void:
	%Raycast.enabled = false
	if sawPlayer:
		return
	if Game.theShade.isActive || !Game.player.is_alive:
		return
	if randf() > Game.theShade.SPAWN_CHANCE:
		return
	_spawn_the_shade()

func _spawn_the_shade() -> void:
	Game.theShade.isActive = true
	var theShade: TheShade = theShadeScene.instantiate()
	self.add_child(theShade)
