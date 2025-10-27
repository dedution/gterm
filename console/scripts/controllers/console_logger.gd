class_name ConsoleLogger
extends Control

@onready var _command_logger : TextEdit = $Logs
var _booted_with_lines: bool = false

func _ready() -> void:
	Console.log_message.connect(add_log)
	Console.log_clear.connect(clear_log)
	
	call_deferred("_scroll_to_bottom")
	if _command_logger.get_line_count() > 0:
		_booted_with_lines = true
		
func add_log(log_tag: String, output: String) -> void:
	var tag : String = "[%s]" % log_tag.to_upper()
	var line = "%s %s" % [tag, output]
	
	if _booted_with_lines:
		line = "\n" + line
		_booted_with_lines = false
		
	_command_logger.text += line + "\n"
	_scroll_to_bottom()

func clear_log() -> void:
	_command_logger.clear()
	_scroll_to_bottom()

func _scroll_to_bottom() -> void:
	_command_logger.scroll_vertical = _command_logger.get_line_count()
