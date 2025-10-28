class_name ConsoleWriter
extends LineEdit

signal text_submit(text: String)

var _command_history: Array[String] = []
var _command_history_max_size: int = 20
var _history_index: int = -1

func _ready() -> void:
	gui_input.connect(_on_input_field_gui_input)
	
func command_history_navigate(is_down : bool = true) -> void:
	text = _command_history.get(_history_index)

func _add_command_to_history(command: String) -> void:
	if _command_history.size() == 0 or _command_history.get(_command_history.size() - 1) != command:
		_command_history.append(command)
		
	if _command_history.size() > _command_history_max_size:
		_command_history.remove_at(0)

func _on_input_field_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			Key.KEY_ENTER:
				if text != "":
					var command = text
					_add_command_to_history(command)
					text_submit.emit(command)
					clear()
				accept_event()
			Key.KEY_UP:
				if _command_history.size() > 0:
					_history_index = max(_history_index - 1, 0)
					text = _command_history[_history_index]
					caret_column = text.length()
					command_history_navigate(false)
					accept_event()
			Key.KEY_DOWN:
				if _command_history.size() > 0:
					_history_index = min(_history_index + 1, _command_history.size())
					if _history_index >= _command_history.size():
						clear()
					else:
						text = _command_history[_history_index]
						caret_column = text.length()
						command_history_navigate(true)
					accept_event()
