class_name DevConsole
extends Control

@onready var command_tree: CommandTree = %CommandTree
@onready var line_edit: LineEdit = %LineEdit
@onready var console_text: RichTextLabel = %RichTextLabel

var command_history: PackedStringArray = []
var command_history_index: int = 0


func _ready() -> void:
	line_edit.text_submitted.connect(_on_submit)
	line_edit.editing_toggled.connect(_on_line_edit_lose_focus)
	
	
func _input(event: InputEvent) -> void:
	if not self.visible:
		return
		
	if event.is_action_pressed(&"dev_console_history_up"):
		_history_up()
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed(&"dev_console_history_down"):
		_history_down()
		get_viewport().set_input_as_handled()
	
	
func _on_line_edit_lose_focus(toggled_on: bool) -> void:
	if self.visible and not toggled_on:
		self.toggle()
		

func _on_submit(command: String) -> void:
	line_edit.clear()
	
	var command_parser := CommandParser.new(command)
	command_parser.tokenize()
	if command_parser.parse_error:
		print_error_console(command_parser.parse_error)
		return
		
	var command_path: Array[CommandTreeNode] = command_tree.get_command_path(
		command_parser.tokens, 
		command_parser.token_types
	)
	if command_tree.error:
		print_error_console(command_tree.error)
		return
		
	command_tree.execute_callback(command_path, command_parser.tokens)
	if command_tree.error:
		print_error_console(command_tree.error)
		return
		
	if command_history.size() == 0 or command != command_history[-1]:
		command_history.push_back(command)
	command_history_index = 0


func _history_down() -> void:
	if command_history_index < 0:
		command_history_index += 1
		if command_history_index == 0:
			line_edit.clear()
		else:
			line_edit.set_text(command_history[command_history_index])
			line_edit.set_caret_column(line_edit.get_text().length())
		
		
func _history_up() -> void:
	if command_history_index > -command_history.size():
		command_history_index -= 1
		line_edit.set_text(command_history[command_history_index])
		line_edit.set_caret_column(line_edit.get_text().length())
		
		
func toggle() -> void:
	Game.player.can_move = self.visible
	self.visible = not self.visible
	if self.visible:
		line_edit.grab_focus()


func print_console(line: String) -> void:
	console_text.newline()
	console_text.append_text(line)


func print_error_console(line: String) -> void:
	console_text.newline()
	console_text.append_text("[color=red]%s[/color]" % line)
