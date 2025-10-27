class_name ConsoleHints
extends Node
@onready var _hints_label : TextEdit = $Root/hints

var _current_tween: Tween = null

func _ready() -> void:
	_animate_root(false)

func process_suggestions(command: String) -> void:
	var input := command
	
	if input == "":
		_hints_label.text = ""
		_animate_root(false)
		return

	var all_commands := Console.commands.get_commands()
	var matches: Array[String] = []

	if input == "/":
		matches = all_commands.duplicate()
	else:
		var parts := input.split(" ", false)
		var user_prefix := parts[0]
		
		if user_prefix.begins_with("/"):
			user_prefix = user_prefix.substr(1, user_prefix.length() - 1)
		user_prefix = user_prefix.to_lower()

		for cmd in all_commands:
			var cmd_name := str(cmd)
			if cmd_name.begins_with("/"):
				cmd_name = cmd_name.substr(1, cmd_name.length() - 1)
			cmd_name = cmd_name.to_lower()

			if cmd_name.begins_with(user_prefix):
				matches.append(str(cmd))

	if matches.size() > 0:
		matches.sort_custom(Callable(self, "_sort_command_matches"))
		_set_hints(matches)
	else:
		_hints_label.text = ""
		_animate_root(false)

func _set_hints(hints_data: Array) -> void:
	var out := ""
	for hint in hints_data:
		out += str(hint) + "\n"
	_hints_label.text = out
	_animate_root(true)

func _sort_command_matches(a, b) -> int:
	if a.length() < b.length():
		return -1
	elif a.length() > b.length():
		return 1
	else:
		# Same length -> alphabetical order
		var a_lower := str(a).to_lower()
		var b_lower := str(b).to_lower()
		if a_lower < b_lower:
			return -1
		elif a_lower > b_lower:
			return 1
		else:
			return 0

func _animate_root(showing: bool) -> void:
	pass
	#var root_node: Control = $Root
#
	#if _current_tween != null and is_instance_valid(_current_tween):
		#_current_tween.kill()
		#_current_tween = null
#
	#var target_y: float = 0.0 if showing else -250.0
#
	#_current_tween = root_node.create_tween()
	#_current_tween.tween_property(root_node, "position:y", target_y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
