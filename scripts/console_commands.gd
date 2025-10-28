class_name ConsoleCommands

var _registered_commands: Dictionary = {}

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
		Console.log_error.emit("console", "Failed to execute command %s" % tokens[0])
		return

	var command_name: String = tokens[0]
	var arg_defs: Array[Argument] = _registered_commands[command_name].arguments
	var action: Callable = _registered_commands[command_name].action

	if arg_defs.size() != tokens.size() - 1:
		Console.log_error.emit("console", "Arguments for command %s don't match" % command_name)
		Console.log_info.emit("console", "Definition:")
		Console.log_info.emit("console", "-- Command name: %s" % command_name)
		for arg_def in arg_defs:
			Console.log_info.emit("console", "-- Argument: %s" % arg_def.argument_name)
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
			Console.log_error.emit("console", "Argument '%s' has invalid type. Expected %s" % [arg_def.argument_name, _type_to_string(arg_def.value_type)])
			return

		parsed_args[arg_def.argument_name] = value

	await action.call(parsed_args)
# Main entry
func run_command(command_full: String) -> void:
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
