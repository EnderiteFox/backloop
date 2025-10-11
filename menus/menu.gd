class_name Menu
extends Control

signal opened
signal closed


var is_open: bool = false

var submenu: Menu: set = _set_submenu


func _unhandled_key_input(event: InputEvent) -> void:
	if self.visible and event.is_action_pressed(&"menu_back"):
		close()
		get_viewport().set_input_as_handled()
		
		
func _set_submenu(new_menu: Menu) -> void:
	if submenu != new_menu:
		if new_menu != null:
			new_menu.closed.connect(_on_menu_close.bind(new_menu))
		if submenu != null:
			submenu.closed.disconnect(_on_menu_close.bind(submenu))
		submenu = new_menu


func _on_menu_close(menu: Menu) -> void:
	if menu == submenu:
		submenu = null
		self.visible = true
		on_focus()


func open() -> void:
	if is_open:
		return
	
	self.visible = true
	is_open = true
	opened.emit()
	on_focus()
	
	
func close() -> void:
	if not is_open:
		return
		
	if submenu != null:
		submenu.close()
		
	self.visible = false
	is_open = false
	closed.emit()
	
	
	
func open_submenu(menu: Menu) -> void:
	if submenu != null:
		submenu.close()
	
	submenu = menu
	menu.open()
	self.visible = false
	

## Called when entering the page
## Used to set the focus to the default element of the menu
func on_focus() -> void:
	pass
