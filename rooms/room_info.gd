## Stores the information for one room type
class_name RoomInfo
extends Resource


## The identifier to use when referring to this room type
@export var id: StringName
## The spawn weight of the room
## The lower, the rarer the room will be
## Defaults to 1.0
@export var spawn_weight: float = 1.0
## The scene of the room
@export_file var scene: Variant
