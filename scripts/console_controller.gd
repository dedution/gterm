class_name ConsoleController
extends Control

@onready var console_window : Window = $Window
@onready var writer : ConsoleWriter = $Window/Container/VBoxContainer/Input/CommandEdit
@onready var logger : ConsoleLogger = $Window/Container/VBoxContainer/Logger

func _ready() -> void:
	console_window.close_requested.connect(_close_menu)
	writer.text_submit.connect(_on_input_submitted)
	_close_menu()

func _open_menu() -> void:
	console_window.visible = true
	console_window.grab_focus()
	writer.grab_focus()
	logger.open_console()
	
func _close_menu() -> void:
	console_window.visible = false
	console_window.gui_release_focus()
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		_open_menu()
		
func _on_input_submitted(command: String) -> void:
	writer.release_focus()
	writer.editable = false
	
	log_info("console", command)
	await ConsoleCommands.run_command(self, command)
	writer.editable = true
	writer.grab_focus()

func log_info(log_tag: String, log : String) -> void:
	if logger:
		logger.add_log_info(log_tag, log)
		
func log_warn(log_tag: String, log : String) -> void:
	if logger:
		logger.add_log_warn(log_tag, log)

func log_error(log_tag: String, log : String) -> void:
	if logger:
		logger.add_log_error(log_tag, log)

func log_clear() -> void:
	if logger:
		logger.clear_log()
