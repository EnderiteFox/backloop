class_name InventoryView
extends Control

@export var inventory: Inventory

@onready var slot_container: Node = %SlotContainer

@onready var battery_bar: TextureProgressBar = %BatteryBar
@onready var battery_bar_animation: AnimationPlayer = %BatteryBarAnimation

var slot_scene: PackedScene = preload("uid://bnbu5ij73yytw")


func _ready() -> void:
	for i in range(inventory.INVENTORY_SLOT_COUNT):
		slot_container.add_child(slot_scene.instantiate())
	
	inventory.item_added.connect(update.unbind(1))
	inventory.item_selected.connect(update.unbind(1))
	
	update()


func update() -> void:
	for node in slot_container.get_children():
		assert(node is InventorySlotUI)
		node.visible = false
	
	assert(inventory.items.size() < Inventory.INVENTORY_SLOT_COUNT)
	
	var children: Array[Node] = slot_container.get_children()
	
	assert(children.size() == Inventory.INVENTORY_SLOT_COUNT)

	for i in range(inventory.items.size()):
		assert(children[i] is InventorySlotUI)
		var slot: InventorySlotUI = children[i]
		slot.set_texture(inventory.items[i].inventory_texture)
		slot.visible = true
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select_next_item") or event.is_action_pressed("select_previous_item"):
		var old_index: int = inventory.selected_item_index
		if event.is_action_pressed("select_next_item"):
			inventory.selected_item_index += 1
		elif event.is_action_pressed("select_previous_item"):
			inventory.selected_item_index -= 1
		change_selected_slot(old_index, inventory.selected_item_index)
		
		
func change_selected_slot(old_slot_index: int, new_slot_index: int) -> void:
	var children: Array[Node] = slot_container.get_children()
	if old_slot_index != -1:
		assert(children[old_slot_index] is InventorySlotUI)
		var slot: InventorySlotUI = children[old_slot_index] as InventorySlotUI
		slot.unselect()
	if new_slot_index != -1:
		assert(children[new_slot_index] is InventorySlotUI)
		var slot: InventorySlotUI = children[new_slot_index] as InventorySlotUI
		slot.select()
