class_name ConsoleController
extends Control

@onready var _console_window : Window = $Window
@onready var _console_writer : ConsoleWriter = $Window/Container/VBoxContainer/Input/CommandEdit

func _ready() -> void:
	_console_window.close_requested.connect(_close_menu)
	_console_writer.text_submit.connect(_on_input_submitted)
	_close_menu()

func _open_menu() -> void:
	_console_window.visible = true
	
func _close_menu() -> void:
	_console_window.visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug"):
		_open_menu()
		
func _on_input_submitted(command: String) -> void:	
	Console.log_info.emit("console", command)
	await Console.commands.run_command(command)
