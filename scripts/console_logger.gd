class_name ConsoleLogger
extends Control

@onready var _command_logger: RichTextLabel = $Logs

const MAX_LOGS: int = 300
var _logs: Array[String] = []
var _first_time: bool = true

func open_console() -> void:
	_print_intro()
	
func _print_intro() -> void:
	if _first_time:
		_first_time = false
	else:
		return

	clear_log()

	var ascii_art: String = r"""
	  ______     ______   ______     ______     __    __    
	 /\  ___\   /\__  _\ /\  ___\   /\  == \   /\ "-./  \   
	 \ \ \__ \  \/_/\ \/ \ \  __\   \ \  __<   \ \ \-./\ \  
	  \ \_____\    \ \_\  \ \_____\  \ \_\ \_\  \ \_\ \ \_\ 
	   \/_____/     \/_/   \/_____/   \/_/ /_/   \/_/  \/_/
	"""
	var current_text = ""
	
	# Animate the ascii art
	var frame_count : int = 0
	var chars_per_frame : int = 3
	for char in ascii_art:
		current_text += char
		frame_count += 1
		if frame_count >= chars_per_frame:
			frame_count = 0
			_logs.clear()
			_logs.append("[color=green]%s[/color]" % current_text)
			_update_display()
			await get_tree().process_frame

	# Footer
	_logs.append("[color=green] Welcome to GTERM by Fabio Barbosa [/color]")
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
