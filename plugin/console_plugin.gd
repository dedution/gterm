@tool
extends EditorPlugin

var singleton_name : String = "Console"
var singleton_path : String = ""

func _enter_tree() -> void:
	var plugin_folder = get_script().resource_path.get_base_dir()
	singleton_path = "%s/../scripts/console.gd" % plugin_folder
	singleton_path = ProjectSettings.localize_path(singleton_path)
	_add_singleton()

func _exit_tree() -> void:
	_remove_singleton()

func _add_singleton() -> void:
	if ProjectSettings.has_setting("autoload/%s" % singleton_name):
		return

	ProjectSettings.set_setting("autoload/%s" % singleton_name, "*%s" % singleton_path)
	ProjectSettings.set_order("autoload/%s" % singleton_name, 0)
	ProjectSettings.save()

	print("[Console Plugin] Singleton '%s' added on top." % singleton_name)

func _remove_singleton() -> void:
	if not ProjectSettings.has_setting("autoload/%s" % singleton_name):
		return
		
	ProjectSettings.set_setting("autoload/%s" % singleton_name, null)
	ProjectSettings.save()
	print("[Console Plugin] Singleton '%s' removed." % singleton_name)
