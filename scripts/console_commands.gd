class_name ConsoleCommands

var _registered_commands: Dictionary = {}

func _init() -> void:
	_register_internal_commands()

func get_commands() -> Array[String]:
	var result: Array[String] = []
	for key in _registered_commands.keys():
		result.append(str(key))
	return result

func register_command(command_name: String, command_arguments: Array[Argument], command_action: Callable) -> void:
	_registered_commands[command_name] = {
		"arguments": command_arguments.duplicate(),
		"action": command_action
	}

# Split a command string by semicolons while respecting quotes
func _split_commands(command_full: String) -> Array[String]:
	var result: Array[String] = []
	var current: String = ""
	var in_quotes: bool = false

	for c in command_full:
		if c == '"':
			in_quotes = not in_quotes
		elif c == ';' and not in_quotes:
			if current.strip_edges() != "":
				result.append(current.strip_edges())
			current = ""
			continue
		current += c

	if current.strip_edges() != "":
		result.append(current.strip_edges())

	return result

func _is_valid_int(s: String) -> bool:
	if s == "":
		return false
	var regex := RegEx.new()
	regex.compile("^[+-]?\\d+$")
	return regex.search(s) != null

func _is_valid_float(s: String) -> bool:
	if s == "":
		return false
	var regex := RegEx.new()
	regex.compile("^[+-]?((\\d+\\.\\d*)|(\\d*\\.\\d+)|\\d+)$")
	return regex.search(s) != null

func _type_to_string(type_const: int) -> String:
	match type_const:
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_BOOL: return "bool"
		TYPE_STRING: return "string"
		_: return "variant"

# Process a single command (array of tokens)
func _process_command(tokens: Array) -> void:
	if tokens.size() == 0 or not _registered_commands.has(tokens[0]):
		Console.log_error("console", "Failed to execute command %s" % tokens[0])
		return

	var command_name: String = tokens[0]
	var arg_defs: Array[Argument] = _registered_commands[command_name].arguments
	var action: Callable = _registered_commands[command_name].action

	if arg_defs.size() != tokens.size() - 1:
		Console.log_error("console", "Arguments for command %s don't match" % command_name)
		Console.log_info("console", "Definition:")
		Console.log_info("console", "-- Command name: %s" % command_name)
		for arg_def in arg_defs:
			Console.log_info("console", "-- Argument: %s" % arg_def.argument_name)
		return

	var parsed_args: Dictionary = {}

	for i in range(arg_defs.size()):
		var arg_def: Argument = arg_defs[i]
		var raw_value: String = tokens[i + 1]
		var value: Variant
		var parse_error: bool = false

		match arg_def.value_type:
			TYPE_FLOAT:
				if _is_valid_float(raw_value):
					value = raw_value.to_float()
				else:
					parse_error = true
			TYPE_INT:
				if _is_valid_int(raw_value):
					value = int(raw_value)
				else:
					parse_error = true
			TYPE_BOOL:
				var lower = raw_value.to_lower()
				if lower in ["true", "false", "1", "0", "yes", "no"]:
					value = lower in ["true", "1", "yes"]
				else:
					parse_error = true
			TYPE_STRING:
				value = raw_value
			_:
				value = raw_value

		if parse_error:
			Console.log_error("console", "Argument '%s' has invalid type. Expected %s" % [arg_def.argument_name, _type_to_string(arg_def.value_type)])
			return

		parsed_args[arg_def.argument_name] = value

	await action.call(parsed_args)
	
# Main entry
func run_command(command_full: String) -> void:
	if not Console.console_is_allowed():
		return
		
	var commands: Array[String] = _split_commands(command_full)

	var regex := RegEx.new()
	regex.compile('("[^"]+"|\\S+)')

	for cmd in commands:
		var matches = regex.search_all(cmd)
		var tokens: Array[String] = []

		for m in matches:
			var token: String = m.get_string(0)
			if token.begins_with('"') and token.ends_with('"'):
				token = token.substr(1, token.length() - 2)
			tokens.append(token)
			
		# Process each command asynchronously
		await _process_command(tokens)


func _register_internal_commands() -> void:
	# /load_mod command
	register_command("/load_mod", [Argument.new("file_name", TYPE_STRING)], func(args: Dictionary) -> void:
		Console.log_info("console", "Loading mod from: %s" % args["file_name"])
	)
	
	# /help command
	register_command("/help", [], _cmd_help)

	# /clear command
	register_command("/clear", [], func(_args: Dictionary) -> void:
		Console.log_clear()
	)
	
	# /pause command
	# Review how this could function
	register_command("/pause", [Argument.new("pause", TYPE_BOOL)], func(args: Dictionary) -> void:
		var pause: bool = true
		if args.has("pause"):
			pause = args["pause"]
		
		Console.get_tree().paused = pause
		Console.log_info("console", "Game paused: %s" % str(pause))
	)
	
	# /set command
	register_command("/set", [
		Argument.new("node_path", TYPE_STRING),
		Argument.new("property", TYPE_STRING),
		Argument.new("value", TYPE_STRING)
	], _cmd_set)
	
	# /version command
	register_command("/version", [], func(_args: Dictionary) -> void:
		Console.log_info("console", "Console version: %s" % Console.get_version())
	)
	
	# /fps command
	register_command("/fps", [], func(_args: Dictionary) -> void:
		Console.log_info("console", "Current FPS: %s" % str(Engine.get_frames_per_second()))
	)
	
	# /resolution command
	register_command("/resolution", [], func(_args: Dictionary) -> void:
		var size = DisplayServer.window_get_size()
		Console.log_info("console", "Current resolution: %dx%d" % [size.x, size.y])
	)
	
	# /network command
	register_command("/network", [], func(_args: Dictionary) -> void:
		Console.log_info("console", "Local addresses:")
		for addr in IP.get_local_addresses():
			Console.log_info("console", "%s" % str(addr))
	)
	
	# /print command
	register_command("/print", [Argument.new("quote", TYPE_STRING)], func(args: Dictionary) -> void:
		Console.log_info("console", args["quote"])
	)

#region Internal
func _cmd_set(args: Dictionary) -> void:
	var node_path: String = args["node_path"]
	var property_name: String = args["property"]
	var value_str: String = args["value"]

	var target_node := Console.get_node_or_null(node_path)
	if target_node == null:
		Console.log_error("console", "Node not found: %s" % node_path)
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
		Console.log_error("console", "Property '%s' not found on node %s" % [property_name, node_path])
		return

	target_node.set(property_name, value)
	Console.log_info("console", "Set %s.%s = %s" % [node_path, property_name, str(value)])

# Print all registered commands
func _cmd_help(_args: Dictionary) -> void:
	var all_cmds: Array[String] = get_commands()
	if all_cmds.size() == 0:
		Console.log_error("console", " - No commands registered -")
	else:
		Console.log_info("console", "Available commands:")
		for cmd in all_cmds:
			Console.log_info("console", "  " + cmd)
