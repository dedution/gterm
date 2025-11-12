class_name ConsoleController
extends Control

@onready var console_window : Window = $Window
@onready var console_writer : ConsoleWriter = $Window/Container/VBoxContainer/Input/CommandEdit
@onready var console_logger : ConsoleLogger = $Window/Container/VBoxContainer/Logger


func _ready() -> void:
	console_window.close_requested.connect(_close_menu)
	console_writer.text_submit.connect(_on_input_submitted)
	_close_menu()

func _open_menu() -> void:
	console_window.visible = true
	console_window.grab_focus()
	console_writer.grab_focus()
	console_logger.open_console()
	
func _close_menu() -> void:
	console_window.visible = false
	console_window.gui_release_focus()
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12 and Console.console_is_allowed():
		_open_menu()
		
func _on_input_submitted(command: String) -> void:
	console_writer.release_focus()
	console_writer.editable = false
	
	if not Console.console_is_allowed():
		log_error("console", "No execution permissions.")
		return
	
	log_info("console", command)
	await Console.run_command(self, command)
	console_writer.editable = true
	console_writer.grab_focus()

func log_info(log_tag: String, log : String) -> void:
	if console_logger:
		console_logger.add_log_info(log_tag, log)
		
func log_warn(log_tag: String, log : String) -> void:
	if console_logger:
		console_logger.add_log_warn(log_tag, log)

func log_error(log_tag: String, log : String) -> void:
	if console_logger:
		console_logger.add_log_error(log_tag, log)

func log_clear() -> void:
	if console_logger:
		console_logger.clear_log()
