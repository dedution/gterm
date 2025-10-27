class_name Argument

var argument_name: String
var value_type: int = TYPE_STRING

func _init(_name: String = "", _type: int = TYPE_STRING, _value: Variant = null) -> void:
	argument_name = _name
	value_type = _type
