extends Node
var _console_controller : ConsoleController

func _ready() -> void:
	if _console_is_allowed():
		ConsoleHelper.register_internal_commands()
		_spawn_menu()
		
func _spawn_menu() -> void:
	var script_file = get_script().resource_path
	var current_folder = script_file.get_base_dir()
	var parent_folder = current_folder.get_base_dir()
	var packed_scene = load(parent_folder + "/%s/%s" % ["scenes", "console.tscn"])
	var instance = packed_scene.instantiate()
	add_child(instance)
	_console_controller = instance

func get_console_controller() -> ConsoleController:
	return _console_controller

func _console_is_allowed() -> bool:
	return OS.is_debug_build()

func get_version() -> String:
	return "1.0.0"
