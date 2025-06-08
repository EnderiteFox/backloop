class_name DevConsole
extends Control

const AUTOCOMPLETE_MENU_OFFSET := Vector2(10, -5)
const AUTOCOMPLETE_HIGHLIGHT_COLOR: String = "coral"
const AUTOCOMPLETE_SELECTED_COLOR: String = "#ffffff22"

@onready var command_tree: CommandTree = %CommandTree
@onready var line_edit: LineEdit = %LineEdit
@onready var console_text: RichTextLabel = %RichTextLabel
@onready var autocomplete_menu: PanelContainer = %AutocompleteMenu
@onready var autocomplete_suggestions: RichTextLabel = %AutocompleteSuggestions

var command_history: PackedStringArray = []
var command_history_index: int = 0
var selected_suggestion_index: int = -1


func _ready() -> void:
	line_edit.text_submitted.connect(_on_submit)
	line_edit.editing_toggled.connect(_on_line_edit_lose_focus)
	line_edit.text_changed.connect(_on_text_changed.unbind(1))
	_update_autocomplete_menu()
	
	
func _input(event: InputEvent) -> void:
	if not self.visible:
		return
		
	if autocomplete_menu.visible:
		if event.is_action_pressed(&"dev_console_suggestion_dismiss"):
			autocomplete_menu.visible = false
			get_viewport().set_input_as_handled()
			return
		
		if event.is_action_pressed(&"dev_console_suggestion_up"):
			_suggestion_up()
			get_viewport().set_input_as_handled()
			return
		
		if event.is_action_pressed(&"dev_console_suggestion_down"):
			_suggestion_down()
			get_viewport().set_input_as_handled()
			return
		
		if event.is_action_pressed(&"dev_console_suggestion_apply"):
			_suggestion_apply()
			get_viewport().set_input_as_handled()
			return
		
	if event.is_action_pressed(&"dev_console_history_up"):
		_history_up()
		get_viewport().set_input_as_handled()
		return
		
	if event.is_action_pressed(&"dev_console_history_down"):
		_history_down()
		get_viewport().set_input_as_handled()
		return
	
	
func _on_line_edit_lose_focus(toggled_on: bool) -> void:
	if self.visible and not toggled_on:
		self.toggle()
		
		
func _update_autocomplete_menu() -> void:
	# Clear suggestions
	autocomplete_suggestions.clear()
		
	# Don't autocomplete if not at least one char
	if line_edit.get_text().length() < 1:
		autocomplete_menu.visible = false
		return
		
	# Get autocomplete suggestions
	var suggestions: Array[String] = command_tree.get_autocomplete_suggestions(line_edit.get_text())
	
	# Set visibility
	autocomplete_menu.visible = not suggestions.is_empty()
	if suggestions.is_empty():
		return
		
	# Get last token
	var command_parser := CommandParser.new(line_edit.get_text(), true)
	command_parser.tokenize()
	var last_token: String = command_parser.tokens[-1] if not command_parser.tokens.is_empty() else ""
	
	# Add elements
	for i in range(suggestions.size()):
		var text: String = suggestions[i].replacen(
			last_token, "[color=%s]%s[/color]" % [AUTOCOMPLETE_HIGHLIGHT_COLOR, last_token]
		) if last_token else suggestions[i]
		
		if i == selected_suggestion_index:
			text = "[bgcolor=%s]%s[/bgcolor]" % [AUTOCOMPLETE_SELECTED_COLOR, text]

		autocomplete_suggestions.append_text(text)
		autocomplete_suggestions.newline()

	# Update menu size
	autocomplete_menu.reset_size()
		
	# Update position
	var pos: Vector2 = line_edit.global_position
	var offset := Vector2(line_edit.get_theme_default_font().get_string_size(line_edit.get_text()).x, 0)
	offset += AUTOCOMPLETE_MENU_OFFSET
	pos += line_edit.get_global_transform().basis_xform_inv(offset)
	pos.y -= autocomplete_menu.get_global_rect().size.y
	autocomplete_menu.global_position = pos


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
	
	
func _on_text_changed() -> void:
	if command_tree.get_autocomplete_suggestions(line_edit.get_text()).is_empty():
		selected_suggestion_index = -1
	else:
		selected_suggestion_index = 0
	_update_autocomplete_menu()


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


func _suggestion_up() -> void:
	if selected_suggestion_index == -1:
		selected_suggestion_index = command_tree.get_autocomplete_suggestions(line_edit.get_text()).size() - 1
	else:
		selected_suggestion_index -= 1
	_update_autocomplete_menu()
		
	
func _suggestion_down() -> void:
	if selected_suggestion_index == command_tree.get_autocomplete_suggestions(line_edit.get_text()).size() - 1:
		selected_suggestion_index = -1
	else:
		selected_suggestion_index += 1
	_update_autocomplete_menu()
	
	
func _suggestion_apply() -> void:
	if selected_suggestion_index == -1:
		return
		
	var suggestions: Array[String] = command_tree.get_autocomplete_suggestions(line_edit.get_text())
	
	if selected_suggestion_index >= suggestions.size():
		return
		
	line_edit.text = CommandParser.replace_last_token(
		line_edit.get_text(), 
		suggestions[selected_suggestion_index]
	)
	line_edit.set_caret_column(line_edit.get_text().length())
	_update_autocomplete_menu()
		
		
func toggle() -> void:
	Game.player.can_move = self.visible
	self.visible = not self.visible
	if self.visible:
		line_edit.clear()
		line_edit.grab_focus()


func print_console(line: String) -> void:
	console_text.newline()
	console_text.append_text(line)


func print_error_console(line: String) -> void:
	console_text.newline()
	console_text.append_text("[color=red]%s[/color]" % line)
	
	
func print_info_console(line: String) -> void:
	console_text.newline()
	console_text.append_text("[color=dim_gray]%s[/color]" % line)
