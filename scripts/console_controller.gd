class_name ConsoleController
extends Control

@onready var console_window : Window = $Window
@onready var _writer : ConsoleWriter = $Window/Container/VBoxContainer/Input/CommandEdit
@onready var _logger : ConsoleLogger = $Window/Container/VBoxContainer/logger

func _ready() -> void:
	console_window.close_requested.connect(_close_menu)
	_writer.text_submit.connect(_on_input_submitted)
	_close_menu()

func _open_menu() -> void:
	console_window.visible = true
	console_window.grab_focus()
	_writer.grab_focus()
	_logger.open_console()
	
func _close_menu() -> void:
	console_window.visible = false
	console_window.gui_release_focus()
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		_open_menu()
		
func _on_input_submitted(command: String) -> void:
	_writer.release_focus()
	_writer.editable = false
	
	log_info("console", command)
	await ConsoleCommands.run_command(self, command)
	_writer.editable = true
	_writer.grab_focus()

func log_info(log_tag: String, output: String) -> void:
	if _logger:
		_logger.add_log(log_tag, output, "white")

func log_warn(log_tag: String, output: String) -> void:
	if _logger:
		_logger.add_log(log_tag, output, "yellow")

func log_error(log_tag: String, output: String) -> void:
	if _logger:
		_logger.add_log(log_tag, output, "red")

func log_clear() -> void:
	if _logger:
		_logger.clear_log()
