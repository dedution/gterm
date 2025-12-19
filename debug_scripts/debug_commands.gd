class_name DebugCommands
extends RefCounted

var _registered_commands: Dictionary = {}

#region Public
func register(command_name: String, command_arguments: Dictionary, command_action: Callable, description : String = "") -> void:
	var arg_list: Array = []
	
	for name in command_arguments.keys():
		arg_list.append(Argument.new(name, command_arguments[name]))

	_registered_commands[command_name] = RegisteredCommand.new(arg_list, command_action, description)

func run(controller: ConsoleController, command_full: String) -> void:
	var commands = _split_commands(command_full)
	for cmd in commands:
		var tokens = _tokenize_command(cmd)
		await _process_command(controller, tokens)

func get_commands() -> Array[String]:
	var result: Array[String] = [] 
	for key in _registered_commands.keys(): 
		result.append(str(key)) 
	return result
	
func get_command_by_id(command_name : String) -> RegisteredCommand:
	if _registered_commands.has(command_name):
		return _registered_commands[command_name]
	return null

#endregion

#region Private
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


func _tokenize_command(command: String) -> Array[String]:
	var regex = RegEx.new()
	regex.compile('("[^"]+"|\\S+)')
	var matches = regex.search_all(command)
	var tokens: Array[String] = []

	for m in matches:
		var token = m.get_string(0)
		if token.begins_with('"') and token.ends_with('"'):
			token = token.substr(1, token.length() - 2)
		tokens.append(token)

	return tokens


func _parse_argument(raw_value: String, type_const: int) -> Variant:
	match type_const:
		TYPE_FLOAT:
			if raw_value.is_valid_float():
				return raw_value.to_float()
		TYPE_INT:
			if raw_value.is_valid_int():
				return int(raw_value)
		TYPE_BOOL:
			var lower = raw_value.to_lower()
			if lower in ["true", "1", "yes"]:
				return true
			elif lower in ["false", "0", "no"]:
				return false
		TYPE_STRING:
			return raw_value
	return null


func _type_to_string(type_const: int) -> String:
	match type_const:
		TYPE_INT:
			return "int"
		TYPE_FLOAT:
			return "float"
		TYPE_BOOL:
			return "bool"
		TYPE_STRING:
			return "string"
		_:
			return "variant"

func _process_command(controller: ConsoleController, tokens: Array) -> void:
	if tokens.is_empty() or not _registered_commands.has(tokens[0]):
		controller.log_error("console", "Failed to execute command [i]%s[/i]" % tokens[0])
		return

	var cmd: RegisteredCommand = _registered_commands[tokens[0]]

	if cmd.arguments.size() > 0 and cmd.arguments.size() != tokens.size() - 1:
		controller.log_error("console", "Arguments for command [i]%s[/i] don't match" % tokens[0])
		controller.log_info("console", "Expected:")
		for argument in cmd.arguments:
			controller.log_info("console", "	[i]%s[/i] (%s)" % [argument.argument_name, _type_to_string(argument.value_type)])
		return

	var parsed_args: Dictionary = {}

	for i in range(cmd.arguments.size()):
		var arg_def: Argument = cmd.arguments[i]
		var raw_value: String = tokens[i + 1]
		var value = _parse_argument(raw_value, arg_def.value_type)

		if value == null:
			controller.log_error(
				"console",
				"Argument '%s' has invalid type. Expected %s" %
				[arg_def.argument_name, _type_to_string(arg_def.value_type)]
			)
			return

		parsed_args[arg_def.argument_name] = value
	
	# Simple commands can have simpler callable parameters
	if cmd.arguments.size() > 0:
		await cmd.action.call(controller, parsed_args)
	else:
		await cmd.action.call(controller)

#endregion

# Helper Classes
class Argument:
	var argument_name: String
	var value_type: int = TYPE_STRING

	func _init(_name: String = "", _type: int = TYPE_STRING) -> void:
		argument_name = _name
		value_type = _type

class RegisteredCommand:
	var arguments: Array
	var action: Callable
	var description: String

	func _init(_args: Array, _action: Callable, _description: String = "") -> void:
		arguments = _args.duplicate()
		action = _action
		description = _description
