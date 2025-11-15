class_name ConsoleLogger
extends Control

@onready var _command_logger: RichTextLabel = $Logs

const MAX_LOGS: int = 300
const INTRO_PATH : String = "%s/../graphics/intro.txt"
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

	var script_folder : String = get_script().resource_path.get_base_dir()
	var intro_anim_path : String = INTRO_PATH % script_folder
	intro_anim_path = ProjectSettings.localize_path(intro_anim_path)
	var ascii_art: String = FileAccess.get_file_as_string(intro_anim_path)
	var current_text = ""
	
	# Animate the ascii art
	var frame_count : int = 0
	var chars_per_frame : int = 5
	for char in ascii_art:
		current_text += char
		frame_count += 1
		if frame_count >= chars_per_frame:
			frame_count = 0
			_logs.clear()
			_logs.append("[color=green]%s[/color]" % current_text)
			_update_display()
			await get_tree().process_frame
	_logs.append("")
	_update_display()

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
