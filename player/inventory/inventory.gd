class_name Inventory
extends Node

signal item_added(item: ItemInstance)

## Emitted when a new item is selected.
## item is the newly selected item, or null for an empty hand.
signal item_selected(item: ItemInstance)
signal selected_item_changed(old_item_index: int, new_item_index: int)

## Emitted when an item is unselected
## Not emitted if you had an empty hand before selecting an item
signal item_unselected(item: ItemInstance)

## Emitted when the count of a consumable changes
signal consumable_count_changed(old_count: int, new_count: int)

const INVENTORY_SLOT_COUNT: int = 6
const INVENTORY_SLOT_SHORTCUTS: Array[StringName] = [
	&"item_slot_1",
	&"item_slot_2",
	&"item_slot_3",
	&"item_slot_4",
	&"item_slot_5",
	&"item_slot_6",
]

var items: Array[ItemInstance]
var consumables: Dictionary[ConsumableInfo.Type, int]

## The index of the currently selected item
## -1 if no item is selected
var selected_item_index: int = -1:
	set = set_selected_index


func _ready() -> void:
	self.item_selected.connect(_on_item_selected)
	self.item_unselected.connect(_on_item_unselected)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
		
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed:
		return
		
	for i in range(INVENTORY_SLOT_SHORTCUTS.size()):
		if event.is_action(INVENTORY_SLOT_SHORTCUTS[i]) and items.size() >= i + 1:
			selected_item_index = i
			break
	
	
func _on_item_selected(item: ItemInstance) -> void:
	if item == null:
		return
	item.is_selected = true
	
	
func _on_item_unselected(item: ItemInstance) -> void:
	item.is_selected = false
	
	
## Adds an already instantiated item to the inventory
func add_item_instance(item_instance: ItemInstance, _item_in_hand: ItemInHand) -> void:
	items.append(item_instance)
	add_child(item_instance)
	item_added.emit(item_instance)
	item_instance.picked_up.emit()


## Instantiates and add an item to the inventory
func add_item(item_info: ItemInfo) -> void:
	var arr: Array = item_info.to_instance()
	add_item_instance(arr[0], arr[1])
	
	
func set_selected_index(new_index: int) -> void:
	if new_index == selected_item_index:
		return
		
	var old_index: int = selected_item_index
		
	if selected_item_index != -1:
		item_unselected.emit(items[selected_item_index])

	if (new_index < -1):
		selected_item_index = items.size() - 1
	elif (new_index >= items.size()):
		selected_item_index = -1
	else:
		selected_item_index = new_index
	item_selected.emit(null if selected_item_index == -1 else items[selected_item_index])
	if selected_item_index != old_index:
		selected_item_changed.emit(old_index, selected_item_index)
	
	
func add_consumable(consumable_type: ConsumableInfo.Type, amount: int = 1) -> void:
	var old_amount: int = get_consumable_count(consumable_type)
	if not consumables.has(consumable_type):
		consumables[consumable_type] = amount
	else:
		consumables[consumable_type] += amount
	consumable_count_changed.emit(old_amount, get_consumable_count(consumable_type))
		
		
func get_consumable_count(consumable_type: ConsumableInfo.Type) -> int:
	if consumables.has(consumable_type):
		return consumables[consumable_type]
	else:
		return 0
