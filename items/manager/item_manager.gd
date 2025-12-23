class_name ItemManager
extends RefCounted


const ITEM_TYPES_FOLDER: String = "res://items/item_types/"
const CONSUMABLE_TYPES_FOLDER: String = "res://items/consumable_types/"


var item_infos: Dictionary[StringName, ItemInfo]
var consumable_infos: Dictionary[StringName, ConsumableInfo]


## Loads item infos and stores them
func load_item_infos() -> void:
	if not item_infos.is_empty() or not consumable_infos.is_empty():
		return
	
	_load_items(ITEM_TYPES_FOLDER)
	_load_consumables(CONSUMABLE_TYPES_FOLDER)
	
	
## Loads items from a folder
## If no item was found in a folder, searches subfolders
## If multiple items are in the same folder, which one is loaded in undetermined
func _load_items(directory: String) -> void:
	var subdirs: Array[String]

	for resource in ResourceLoader.list_directory(directory):
		if resource.ends_with("/"):
			subdirs.append(directory + resource)
		elif resource.get_extension() == "tres":
			var loaded: Resource = load(directory + resource)
			if not loaded is ItemInfo:
				continue
			item_infos[loaded.id] = loaded
			return
			
	for dir in subdirs:
		_load_items(dir)
	
	
## Loads consumables from a folder
## If no consumable was found in the folder, searches subfolders
## If multiple consumables are in the same folder, which one is loaded in undetermined
func _load_consumables(directory: String) -> void:
	var subdirs: Array[String]
	
	for resource in ResourceLoader.list_directory(directory):
		if resource.ends_with("/"):
			subdirs.append(directory + resource)
		elif resource.get_extension() == "tres":
			var loaded: Resource = load(directory + resource)
			if not loaded is ConsumableInfo:
				continue
			consumable_infos[loaded.id] = loaded
			return
			
	for dir in subdirs:
		_load_consumables(dir)
