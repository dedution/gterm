class_name ConsoleLogger
extends Control

@onready var _command_logger: RichTextLabel = $Logs

const MAX_LOGS: int = 300
var _logs: Array[String] = []

func _ready() -> void:
	print_into()
	
func print_into() -> void:
	clear_log()
	_logs.append("[color=green] Welcome to GTERM by Fabio B [/color]")
	_logs.append("[color=green] Version %s [/color]" % Console.get_version())
	_update_display()

func add_log_info(log_tag: String, output: String) -> void:
	add_log(log_tag, output, "white")

func add_log_warn(log_tag: String, output: String) -> void:
	add_log(log_tag, output, "yellow")

func add_log_error(log_tag: String, output: String) -> void:
	add_log(log_tag, output, "red")

func add_log(log_tag: String, output: String, color: String = "white") -> void:
	var line: String = "[color=%s][%s] %s[/color]" % [color, log_tag.to_upper(), output]
	_logs.append(line)
	if _logs.size() > MAX_LOGS:
		_logs.pop_front()

	_update_display()

func clear_log() -> void:
	_logs.clear()
	_update_display()

func _update_display() -> void:
	var bbcode_text: String = ""
	for log_line in _logs:
		bbcode_text += log_line + "\n"

	_command_logger.parse_bbcode(bbcode_text)
	_command_logger.scroll_to_line(_command_logger.get_line_count() - 1)
