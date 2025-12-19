extends Node

@export var features_dir : String = "res://addons/"
@export var feature_marker : String = "debug_config.cfg"
@export var allowed_in_editor : bool = true
@export var allowed_in_debug : bool = true

var _features: Dictionary[String, DebugFeature] = {}
var commands: DebugCommands = DebugCommands.new()

# Signal dispatcher
signal feature_loaded(feature_name: String, instance: DebugFeature)

func _ready() -> void:
	if not _is_allowed():
		return
	_load_features()

func _is_allowed() -> bool:
	return (allowed_in_editor and Engine.is_editor_hint()) or (allowed_in_debug and OS.is_debug_build())

func _load_features() -> void:
	var dir = DirAccess.open(features_dir)
	if not dir:
		return

	for folder_name in dir.get_directories():
		if not folder_name.begins_with("."):
			_load_feature(folder_name)

func _load_feature(folder_name: String):
	var feature_path = "%s/%s" % [features_dir, folder_name]
	var cfg_path = feature_path + "/" + feature_marker

	if not FileAccess.file_exists(cfg_path):
		return # skip if no marker

	# Load config
	var cfg = ConfigFile.new()
	var err = cfg.load(cfg_path)
	if err != OK:
		return

	var feature_name = cfg.get_value("Feature", "feature_name", folder_name)
	var script_path = cfg.get_value("Feature", "script", "")
	if script_path == "":
		return

	# Create a Node to hold the feature
	var node_instance := Node.new()
	node_instance.name = feature_name
	add_child(node_instance)

	# Load the script
	var script_res := load(feature_path + "/" + script_path)
	if not script_res:
		return

	# Assign the script to the node
	node_instance.set_script(script_res)

	# If the script extends DebugFeature, call init_feature
	if node_instance is DebugFeature:
		node_instance.init_feature()

	# Store in features dictionary
	_features[feature_name] = node_instance
	feature_loaded.emit(feature_name, node_instance)

# Call a specific method on a feature and get the results
func call_feature(feature_name: String, function_name: String, ...args) -> Variant:
	var feature: DebugFeature = _features.get(feature_name, null)
	if feature and feature.has_method(function_name):
		return feature.callv(function_name, args)
	return null

func get_feature(feature_name: String) -> DebugFeature:
	return _features.get(feature_name, null)

func get_features() -> Array:
	return _features.keys()
