class_name TheShadeSpawnPoint
extends RoomElement

var theShadeScene: PackedScene = preload("res://mobs/the_shade/the_shade.tscn")

func _ready() -> void:
	super._ready()
	room.room_opened.connect(_on_room_open)

	
func _physics_process(_delta: float) -> void:
	%Raycast.target_position = %Raycast.to_local(Game.player.camera.global_position)
	if %Raycast.get_collider() is Player:
		Game.theShade.spawn_points[room].erase(self)
		self.queue_free()
	

func _on_room_open() -> void:
	%Raycast.enabled = true
	
	if not Game.theShade.spawn_points.has(room):
		Game.theShade.spawn_points[room] = []
		
	Game.theShade.spawn_points[room].append(self)


func spawn_the_shade() -> void:
	Game.theShade.isActive = true
	var theShade: TheShade = theShadeScene.instantiate()
	var globalRotation: Vector3 = self.global_rotation
	var globalPosition: Vector3 = self.global_position
	self.replace_by(theShade)
	theShade.global_rotation = globalRotation
	theShade.global_position = globalPosition
	self.queue_free()
