class_name ConsoleController
extends Control

@onready var _console_writer : LineEdit = $Window/Container/VBoxContainer/Input/CommandWriter
@onready var _console_hints : ConsoleHints = $Window/Container/VBoxContainer/Hints
@onready var _console_window : Window = $Window

var _is_locked : bool = false
var _console_history: Array[String] = []
var _console_history_max_size: int = 20
var _history_index: int = -1
var _current_tween: Tween = null
var _is_enabled : bool = false

func _ready() -> void:
	_console_writer.gui_input.connect(_on_input_field_gui_input)
	_console_writer.text_changed.connect(_process_suggestions)
	_console_window.close_requested.connect(_close_menu)
	_animate(true)

func _open_menu() -> void:
	_console_writer.grab_focus()
	_console_window.visible = true
	
func _close_menu() -> void:
	_console_window.visible = false
	
func _add_console_to_history(command: String) -> void:
	if _console_history.size() == 0 or _console_history.get(_console_history.size() - 1) != command:
		_console_history.append(command)
		
	if _console_history.size() > _console_history_max_size:
		_console_history.remove_at(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug") and !_is_locked:
		_is_enabled = !_is_enabled
		
		if _is_enabled:
			_open_menu()
		_animate()

func command_history_navigate(is_down : bool = true) -> void:
	_console_writer.text = _console_history.get(_history_index)

func _on_input_submitted(command: String) -> void:
	if not command.begins_with("/"):
		Console.log_message.emit("console", "Unknown command: %s" % command)
		return
		
	Console.log_message.emit("console", command)
	_add_console_to_history(command)
	_process_console(command)

func _process_suggestions(text : String) -> void:
	_console_hints.process_suggestions(text)
	
func _process_console(command: String) -> void:
	_is_locked = true
	await Console.commands.run_command(command)
	_is_locked = false

func _animate(instant: bool = false) -> void:
	pass

func _on_input_field_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not _is_locked:
		match event.keycode:
			Key.KEY_ENTER:
				if _console_writer.text != "":
					var command = _console_writer.text
					_on_input_submitted(command)
					_console_writer.clear()
				_console_writer.grab_focus()
				accept_event()
			Key.KEY_UP:
				if _console_history.size() > 0:
					_history_index = max(_history_index - 1, 0)
					_console_writer.text = _console_history[_history_index]
					_console_writer.caret_column = _console_writer.text.length()
					command_history_navigate(false)
					accept_event()
			Key.KEY_DOWN:
				if _console_history.size() > 0:
					_history_index = min(_history_index + 1, _console_history.size())
					if _history_index >= _console_history.size():
						_console_writer.clear()
					else:
						_console_writer.text = _console_history[_history_index]
						_console_writer.caret_column = _console_writer.text.length()
						command_history_navigate(true)
					accept_event()
