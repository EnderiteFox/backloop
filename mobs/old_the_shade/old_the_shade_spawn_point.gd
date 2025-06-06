class_name OldTheShadeSpawnPoint
extends RoomElement

var theShadeScene: PackedScene = preload("uid://c75184mf0hfkg")

func _ready() -> void:
	super._ready()
	room.room_opened.connect(_on_room_open)

	
func _physics_process(_delta: float) -> void:
	%Raycast.target_position = %Raycast.to_local(Game.player.camera.global_position)
	if %Raycast.get_collider() is Player:
		Game.oldTheShade.spawn_points[room].erase(self)
		self.queue_free()
	

func _on_room_open() -> void:
	%Raycast.enabled = true
	
	if not Game.oldTheShade.spawn_points.has(room):
		Game.oldTheShade.spawn_points[room] = []
		
	Game.oldTheShade.spawn_points[room].append(self)


func spawn_the_shade() -> void:
	Game.oldTheShade.isActive = true
	var theShade: OldTheShade = theShadeScene.instantiate()
	var globalRotation: Vector3 = self.global_rotation
	var globalPosition: Vector3 = self.global_position
	self.replace_by(theShade)
	theShade.global_rotation = globalRotation
	theShade.global_position = globalPosition
	self.queue_free()
