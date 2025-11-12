@tool
extends EditorPlugin

var singleton_name := "Console"
var singleton_path := ""

func _enter_tree() -> void:
	var plugin_folder = get_script().resource_path.get_base_dir()
	singleton_path = "%s/../scripts/console.gd" % plugin_folder
	singleton_path = ProjectSettings.localize_path(singleton_path)
	
	_add_singleton()

func _exit_tree() -> void:
	_remove_singleton()

# -------------------------
# Add Console as top singleton
# -------------------------
func _add_singleton() -> void:
	var autoloads: Dictionary = ProjectSettings.get("autoload")
	if singleton_name in autoloads:
		_move_to_top(singleton_name)
		return

	ProjectSettings.set_setting("autoload/%s/path" % singleton_name, singleton_path)
	ProjectSettings.set_setting("autoload/%s/enabled" % singleton_name, true)
	ProjectSettings.set_setting("autoload/%s/load" % singleton_name, true)
	ProjectSettings.save()

	_move_to_top(singleton_name)
	print("[Console Plugin] Singleton '%s' added on top." % singleton_name)

# -------------------------
# Remove Console singleton
# -------------------------
func _remove_singleton() -> void:
	var autoloads: Dictionary = ProjectSettings.get("autoload")
	if singleton_name in autoloads:
		ProjectSettings.set_setting("autoload/%s/path" % singleton_name, null)
		ProjectSettings.set_setting("autoload/%s/enabled" % singleton_name, null)
		ProjectSettings.set_setting("autoload/%s/load" % singleton_name, null)
		ProjectSettings.save()
		print("[Console Plugin] Singleton '%s' removed." % singleton_name)

# -------------------------
# Move the autoload to top
# -------------------------
func _move_to_top(name: String) -> void:
	var path = ProjectSettings.get_setting("autoload/%s/path" % name)
	var enabled = ProjectSettings.get_setting("autoload/%s/enabled" % name)
	var load = ProjectSettings.get_setting("autoload/%s/load" % name)
	
	ProjectSettings.set_setting("autoload/%s/path" % name, path)
	ProjectSettings.set_setting("autoload/%s/enabled" % name, enabled)
	ProjectSettings.set_setting("autoload/%s/load" % name, load)
	ProjectSettings.save()
