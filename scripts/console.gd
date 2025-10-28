extends Node
var commands: ConsoleCommands

signal log_info(log_tag: String, log : String)
signal log_warn(log_tag: String, log : String)
signal log_error(log_tag: String, log : String)
signal log_clear()

var _version : String = "0.0.1"

func _ready() -> void:
	commands = ConsoleCommands.new()
	_register_internal_commands()
	_spawn_menu()

func _is_valid_int(s: String) -> bool:
	if s == "":
		return false
	var regex := RegEx.new()
	regex.compile("^[+-]?\\d+$")
	return regex.search(s) != null

func _register_internal_commands() -> void:
	# /wait command
	commands.register_command("/wait", [Argument.new("time", TYPE_FLOAT)], func(args: Dictionary) -> void:
		var time: float = args["time"]
		await get_tree().create_timer(time).timeout
		log_info.emit("console", "Waited %.1f" % time)
	)
	
	# /loadmod command
	commands.register_command("/loadmod", [Argument.new("file_name", TYPE_STRING)], func(args: Dictionary) -> void:
		log_info.emit("console", "Loading mod from: %s" % args["file_name"])
	)
	
	# /help command
	commands.register_command("/help", [], _cmd_help)

	# /clear command
	commands.register_command("/clear", [], func(args: Dictionary) -> void:
		log_clear.emit()
	)
	
	# /pause command
	commands.register_command("/pause", [Argument.new("pause", TYPE_BOOL)], _cmd_pause)
	
	# /set command
	commands.register_command("/set", [
		Argument.new("node_path", TYPE_STRING),
		Argument.new("property", TYPE_STRING),
		Argument.new("value", TYPE_STRING)
	], _cmd_set)
	
	# /version command
	commands.register_command("/version", [], func(args: Dictionary) -> void:
		log_info.emit("console", "Console version: %s" % _version)
	)
	
	# /fps command
	commands.register_command("/fps", [], func(args: Dictionary) -> void:
		log_info.emit("console", "Current FPS: %s" % str(Engine.get_frames_per_second()))
	)
	
	# /print command
	commands.register_command("/print", [Argument.new("quote", TYPE_STRING)], func(args: Dictionary) -> void:
		log_info.emit("console", args["quote"])
	)

func _cmd_pause(args: Dictionary) -> void:
	var pause: bool = true
	if args.has("pause"):
		pause = args["pause"]
	
	get_tree().paused = pause
	log_info.emit("console", "Game paused: %s" % str(pause))


func _cmd_set(args: Dictionary) -> void:
	var node_path: String = args["node_path"]
	var property_name: String = args["property"]
	var value_str: String = args["value"]

	var target_node := get_node_or_null(node_path)
	if target_node == null:
		log_error.emit("console", "Node not found: %s" % node_path)
		return

	# Try to convert the value to a sensible type
	var value: Variant = value_str
	if _is_valid_int(value_str):
		value = int(value_str)
	elif value_str.is_valid_float():
		value = float(value_str)
	elif value_str.to_lower() in ["true", "false"]:
		value = value_str.to_lower() == "true"

	if not target_node.has_property(property_name):
		log_error.emit("console", "Property '%s' not found on node %s" % [property_name, node_path])
		return

	target_node.set(property_name, value)
	log_info.emit("console", "Set %s.%s = %s" % [node_path, property_name, str(value)])

func _cmd_help(args: Dictionary) -> void:
	var all_cmds: Array[String] = commands.get_commands()
	if all_cmds.size() == 0:
		log_error.emit("console", " - No commands registered -")
	else:
		log_info.emit("console", "Available commands:")
		for cmd in all_cmds:
			log_info.emit("console", "  " + cmd)

func _spawn_menu() -> void:
	var script_file = get_script().resource_path
	var current_folder = script_file.get_base_dir()
	var parent_folder = current_folder.get_base_dir()
	var packed_scene = load(parent_folder + "/%s/%s" % ["scenes", "console.tscn"])
	var instance = packed_scene.instantiate()
	add_child(instance)
