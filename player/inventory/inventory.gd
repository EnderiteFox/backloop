class_name Inventory
extends Node

signal item_added(item: Item)

## Emitted when a new item is selected.
## item is the newly selected item, or null for an empty hand.
signal item_selected(item: Item)

## Emitted when an item is unselected
## Not emitted if you had an empty hand before selecting an item
signal item_unselected(item: Item)

## Emitted when the count of a consumable changes
signal consumable_count_changed(old_count: int, new_count: int)

const INVENTORY_SLOT_COUNT: int = 6

var items: Array[Item]
var consumables: Dictionary[Consumable.Type, int]

## The index of the currently selected item. -1  if no item is selected
var selected_item_index: int = -1:
	set = set_selected_index


func _ready() -> void:
	self.item_selected.connect(_on_item_selected)
	self.item_unselected.connect(_on_item_unselected)
	
	
func _on_item_selected(item: Item) -> void:
	if item == null:
		return
	item.is_selected = true
	
	
func _on_item_unselected(item: Item) -> void:
	item.is_selected = false


func add_item(item: Item) -> void:
	items.append(item)
	self.add_child(item)
	item_added.emit(item)
	
	
func set_selected_index(new_index: int) -> void:
	if new_index == selected_item_index:
		return
		
	if selected_item_index != -1:
		item_unselected.emit(items[selected_item_index])

	if (new_index < -1):
		selected_item_index = items.size() - 1
	elif (new_index >= items.size()):
		selected_item_index = -1
	else:
		selected_item_index = new_index
	item_selected.emit(null if selected_item_index == -1 else items[selected_item_index])
	
	
func add_consumable(consumable_type: Consumable.Type, amount: int = 1) -> void:
	var old_amount: int = get_consumable_count(consumable_type)
	if not consumables.has(consumable_type):
		consumables[consumable_type] = amount
	else:
		consumables[consumable_type] += amount
	consumable_count_changed.emit(old_amount, get_consumable_count(consumable_type))
		
		
func get_consumable_count(consumable_type: Consumable.Type) -> int:
	if consumables.has(consumable_type):
		return consumables[consumable_type]
	else:
		return 0
