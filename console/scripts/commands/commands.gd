class_name ConsoleCommands

var _registered_commands: Dictionary = {}

func get_commands() -> Array[String]:
	var result: Array[String] = []
	for key in _registered_commands.keys():
		result.append(str(key))
	return result

func register_command(command_name: String, command_arguments: Array[Argument], command_action: Callable) -> void:
	_registered_commands[command_name] = {}
	_registered_commands[command_name].arguments = command_arguments.duplicate()
	_registered_commands[command_name].action = command_action

func run_command(command_full: String) -> void:
	var regex := RegEx.new()
	regex.compile('("[^"]+"|\\S+)')
	var matches := regex.search_all(command_full)

	var command: Array = []
	for m in matches:
		var token: String = m.get_string(0)
		if token.begins_with('"') and token.ends_with('"'):
			token = token.substr(1, token.length() - 2)
		command.append(token)

	if command.size() == 0 or not _registered_commands.has(command[0]):
		Console.log_message.emit("console", "Failed to execute command %s" % command_full)
		return

	var arguments_definitions: Array[Argument] = _registered_commands[command[0]].arguments
	var arguments_parsed: Dictionary = {}
	var action: Callable = _registered_commands[command[0]].action

	if arguments_definitions.size() != command.size() - 1:
		Console.log_message.emit("console", "Arguments for command %s don't match" % command[0])
		Console.log_message.emit("console", "Definition:")
		Console.log_message.emit("console", "-- Command name: %s" % command[0])
		for arg in arguments_definitions:
			Console.log_message.emit("console", "-- Argument: %s" % arg.argument_name)
		return

	if arguments_definitions.size() > 0:
		for arg_index in range(arguments_definitions.size()):
			var arg_def: Argument = arguments_definitions[arg_index]
			var raw_value: String = command[arg_index + 1]
			var value: Variant

			match arg_def.value_type:
				TYPE_FLOAT:
					value = float(raw_value)
				TYPE_INT:
					value = int(raw_value)
				TYPE_BOOL:
					value = raw_value.to_lower() in ["true", "1", "yes"]
				TYPE_STRING:
					value = raw_value
				_:
					value = raw_value

			arguments_parsed[arg_def.argument_name] = value

	await action.call(arguments_parsed)
