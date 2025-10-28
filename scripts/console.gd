extends Node
var commands: ConsoleCommands

signal log_info(log_tag: String, log : String)
signal log_warn(log_tag: String, log : String)
signal log_error(log_tag: String, log : String)
signal log_clear()

var _version : String = "0.0.1"

func _ready() -> void:
	commands = ConsoleCommands.new()
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

#endregion
