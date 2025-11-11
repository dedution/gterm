extends Node

var _version : String = "0.0.1"
var commands: ConsoleCommands
var console_controller: ConsoleController

func _ready() -> void:
	commands = ConsoleCommands.new()
	
	if console_is_allowed():
		_spawn_menu()

func _spawn_menu() -> void:
	var script_file = get_script().resource_path
	var current_folder = script_file.get_base_dir()
	var parent_folder = current_folder.get_base_dir()
	var packed_scene = load(parent_folder + "/%s/%s" % ["scenes", "console.tscn"])
	var instance = packed_scene.instantiate()
	add_child(instance)
	console_controller = instance

func get_version() -> String:
	return _version
	
func console_is_allowed() -> bool:
	return OS.is_debug_build()

#region Logging
func log_info(log_tag: String, log : String) -> void:
	if console_controller:
		console_controller.console_logger.add_log_info(log_tag, log)
		
func log_warn(log_tag: String, log : String) -> void:
	if console_controller:
		console_controller.console_logger.add_log_warn(log_tag, log)

func log_error(log_tag: String, log : String) -> void:
	if console_controller:
		console_controller.console_logger.add_log_error(log_tag, log)

func log_clear() -> void:
	if console_controller:
		console_controller.console_logger.clear_log()

#endregion
