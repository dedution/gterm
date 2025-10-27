class_name ConsoleController
extends Control

@onready var _command_writer : LineEdit = $Window/Container/Input/CommandWriter
@onready var _command_hints : ConsoleHints = $Window/Container/Hints

var _is_locked : bool = false

var _command_history: Array[String] = []
var _command_history_max_size: int = 20
var _history_index: int = -1
var _current_tween: Tween = null
var _is_enabled : bool = false

func _ready() -> void:
	_command_writer.gui_input.connect(_on_input_field_gui_input)
	_command_writer.text_changed.connect(_process_suggestions)
	_animate(true)

func _open_menu() -> void:
	_command_writer.grab_focus()
	
func _add_command_to_history(command: String) -> void:
	if _command_history.size() == 0 or _command_history.get(_command_history.size() - 1) != command:
		_command_history.append(command)
		
	if _command_history.size() > _command_history_max_size:
		_command_history.remove_at(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug") and !_is_locked:
		_is_enabled = !_is_enabled
		
		if _is_enabled:
			_open_menu()
		_animate()

func command_history_navigate(is_down : bool = true) -> void:
	_command_writer.text = _command_history.get(_history_index)

func _on_input_submitted(command: String) -> void:
	if not command.begins_with("/"):
		Console.log_message.emit("console", "Unknown command: %s" % command)
		return
		
	Console.log_message.emit("console", command)
	_add_command_to_history(command)
	_process_command(command)

func _process_suggestions(text : String) -> void:
	_command_hints.process_suggestions(text)
	
func _process_command(command: String) -> void:
	_is_locked = true
	await Console.commands.run_command(command)
	_is_locked = false

func _animate(instant: bool = false) -> void:
	pass
	# visible = _is_enabled
	#if _current_tween != null and is_instance_valid(_current_tween):
		#_current_tween.kill()
		#_current_tween = null
#
	#var target_height: float = 1080.0 if _is_enabled else 0.0
	#var target_size: Vector2 = Vector2(self.size.x, target_height)
#
	#if instant:
		#self.size = target_size  # Instantly set the size
	#else:
		#_current_tween = self.create_tween()
		#if _current_tween != null:
			#_current_tween.tween_property(self, "size", target_size, 0.25)
			#_current_tween.set_trans(Tween.TRANS_QUAD)
			#_current_tween.set_ease(Tween.EASE_OUT)

func _on_input_field_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not _is_locked:
		match event.keycode:
			Key.KEY_ENTER:
				if _command_writer.text != "":
					var command = _command_writer.text
					_on_input_submitted(command)
					_command_writer.clear()
				_command_writer.grab_focus()
				accept_event()
			Key.KEY_UP:
				if _command_history.size() > 0:
					_history_index = max(_history_index - 1, 0)
					_command_writer.text = _command_history[_history_index]
					_command_writer.caret_column = _command_writer.text.length()
					command_history_navigate(false)
					accept_event()
			Key.KEY_DOWN:
				if _command_history.size() > 0:
					_history_index = min(_history_index + 1, _command_history.size())
					if _history_index >= _command_history.size():
						_command_writer.clear()
					else:
						_command_writer.text = _command_history[_history_index]
						_command_writer.caret_column = _command_writer.text.length()
						command_history_navigate(true)
					accept_event()
