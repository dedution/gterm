class_name Console
extends DebugFeature
var _console_controller : ConsoleController

func init_feature() -> void:
	ConsoleCommands.register_all()
	_spawn_menu()
		
func _spawn_menu() -> void:
	var script_file = get_script().resource_path
	var current_folder = script_file.get_base_dir()
	var parent_folder = current_folder.get_base_dir()
	var packed_scene = load(parent_folder + "/%s/%s" % ["scenes", "console.tscn"])
	var instance = packed_scene.instantiate()
	add_child(instance)
	_console_controller = instance

static func get_version() -> String:
	return "1.0.0"
