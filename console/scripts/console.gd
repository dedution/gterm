extends Node
var commands: ConsoleCommands

signal log_message(log_tag: String, log : String)
signal log_clear()

func _ready() -> void:
	commands = ConsoleCommands.new()
	_register_internal_commands()
	_spawn_menu()

func _register_internal_commands() -> void:
	# /wait command
	commands.register_command("/wait", [Argument.new("time", TYPE_FLOAT)], func(args: Dictionary) -> void:
		var time: float = args["time"]
		await get_tree().create_timer(time).timeout
		log_message.emit("console", "Waited %.1f" % time)
	)

	# /clear command
	commands.register_command("/clear", [], func(_args: Dictionary) -> void:
		log_clear.emit()
	)

	# /print command
	commands.register_command("/print", [Argument.new("quote", TYPE_STRING)], func(args: Dictionary) -> void:
		log_message.emit("console", args["quote"])
	)

func _spawn_menu() -> void:
	var script_file = get_script().resource_path
	var current_folder = script_file.get_base_dir()
	var parent_folder = current_folder.get_base_dir()
	var packed_scene = load(parent_folder + "/%s/%s" % ["scenes", "console.tscn"])
	
	var instance = packed_scene.instantiate()
	add_child(instance)
