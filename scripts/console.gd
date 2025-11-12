extends Node

var _version : String = "0.0.1"
var _commands: ConsoleCommands

func _ready() -> void:
	_commands = ConsoleCommands.new()
	
	if console_is_allowed():
		_spawn_menu()

func _spawn_menu() -> void:
	var script_file = get_script().resource_path
	var current_folder = script_file.get_base_dir()
	var parent_folder = current_folder.get_base_dir()
	var packed_scene = load(parent_folder + "/%s/%s" % ["scenes", "console.tscn"])
	var instance = packed_scene.instantiate()
	add_child(instance)

func get_version() -> String:
	return _version
	
func console_is_allowed() -> bool:
	return OS.is_debug_build()

func get_commands() -> Array[String]:
	return _commands.get_commands()

func register_command(command_name: String, command_arguments: Array[Argument], command_action: Callable) -> void:
	_commands.register_command(command_name, command_arguments, command_action)

func run_command(controller: ConsoleController, command_full: String) -> void:
	_commands.run_command(controller, command_full)
