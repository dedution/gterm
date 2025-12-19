class_name ConsoleCommands

static func register_all() -> void:
	var cmds = Debug.commands

	cmds.register("/sleep", {"time": TYPE_FLOAT}, cmd_sleep, "Sleeps for a given time")
	cmds.register("/exec", {"file_name": TYPE_STRING}, cmd_exec, "Executes a .cfg file containing commands")
	cmds.register("/load_mod", {"file_name": TYPE_STRING}, cmd_load_mod, "Loads a .pck mod file")
	cmds.register("/load_script", {"file_name": TYPE_STRING}, cmd_load_script, "Loads a .gd script and executes its 'run' function")
	cmds.register("/clear", {}, cmd_clear, "Clears console logs")
	cmds.register("/pause", {"pause": TYPE_BOOL}, cmd_pause, "Pauses and unpauses the game")
	cmds.register("/game-speed", {"time": TYPE_FLOAT}, cmd_game_speed, "Sets the current game speed")
	cmds.register("/version", {}, cmd_version, "Prints the console version")
	cmds.register("/stats", {}, cmd_stats, "Prints game performance related stats")
	cmds.register("/network", {}, cmd_network, "Prints network related stats")
	cmds.register("/print", {"text": TYPE_STRING}, cmd_print, "Prints words into the console")
	cmds.register("/help", {}, cmd_help, "Lists the available commands")

static func cmd_sleep(controller: ConsoleController, args: Dictionary) -> void:
	await controller.get_tree().create_timer(args["time"]).timeout

static func cmd_exec(controller: ConsoleController, args: Dictionary) -> void:
	var code = _read_file(args["file_name"])
	if code == "":
		controller.log_error("console", "File not found or invalid!")
		return
	Debug.commands.run(controller, code)

static func cmd_load_mod(controller: ConsoleController, args: Dictionary) -> void:
	var mod_file = ProjectSettings.globalize_path(args.get("file_name", ""))
	if mod_file == "" or not FileAccess.file_exists(mod_file):
		controller.log_warn("PCKLoader", "PCK file not found: %s" % mod_file)
		return
	if ProjectSettings.load_resource_pack(mod_file):
		controller.log_info("PCKLoader", "Successfully loaded: %s" % mod_file)
	else:
		controller.log_error("PCKLoader", "Failed to load PCK: %s" % mod_file)

static func cmd_load_script(controller: ConsoleController, args: Dictionary) -> void:
	var script_code = _read_file(args["file_name"])
	if script_code == "":
		controller.log_error("console", "File not found or invalid!")
		return
	controller.log_info("console", "Compiling %s..." % args["file_name"])
	_run_text_script(controller, script_code)

static func cmd_clear(controller: ConsoleController, args: Dictionary = {}) -> void:
	controller.log_clear()

static func cmd_pause(controller: ConsoleController, args: Dictionary) -> void:
	var pause: bool = args.get("pause", true)
	Engine.time_scale = 0.0 if pause else 1.0
	controller.log_info("console", "Game paused: %s" % str(pause))

static func cmd_game_speed(controller: ConsoleController, args: Dictionary) -> void:
	var time: float = args.get("time", 1.0)
	Engine.time_scale = time
	controller.log_info("console", "Game speed set to: %s" % str(Engine.time_scale))

static func cmd_version(controller: ConsoleController) -> void:
	controller.log_info("console", "Console version: %s" % Console.get_version())

static func cmd_stats(controller: ConsoleController) -> void:
	controller.log_info("console", "Current FPS: %s" % str(Engine.get_frames_per_second()))
	var size = DisplayServer.window_get_size()
	controller.log_info("console", "Current resolution: %dx%d" % [size.x, size.y])

static func cmd_network(controller: ConsoleController, args: Dictionary = {}) -> void:
	controller.log_info("console", "Machine network address: %s" % get_local_ip())

static func cmd_print(controller: ConsoleController, args: Dictionary) -> void:
	controller.log_info("console", args["text"])

static func cmd_help(controller: ConsoleController, args: Dictionary = {}) -> void:
	var all_cmds: Array[String] = Debug.commands.get_commands()
	if all_cmds.is_empty():
		controller.log_error("console", " - No commands registered -")
	else:
		controller.log_rainbow("console", "Available commands:")
		for cmd in all_cmds:
			var cmd_description: String = Debug.commands.get_command_by_id(cmd).description
			if cmd_description.is_empty():
				controller.log_info("console", "  [i]%s[/i]" % [cmd])
			else:
				controller.log_info("console", "  [i]%s[/i] - (%s)" % [cmd, cmd_description])

# ----------------------------
# Private helpers
# ----------------------------
static func _read_file(relative_path: String) -> String:
	if relative_path.is_empty():
		return ""
	var file_path: String
	if OS.has_feature("editor"):
		file_path = ProjectSettings.globalize_path("res://") + relative_path
	else:
		file_path = OS.get_executable_path().get_base_dir() + "/" + relative_path
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return ""
	var content = file.get_as_text()
	file.close()
	return content

static func get_local_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.count(".") == 3 and not ip.begins_with("127."):
			if ip.begins_with("10.") or ip.begins_with("192.168.") or (ip.begins_with("172.") and int(ip.split(".")[1]) in range(16,32)):
				return ip
	return "127.0.0.1"

static func _run_text_script(controller: ConsoleController, code: String) -> void:
	var script = GDScript.new()
	script.source_code = code
	var error = script.reload()
	if error == OK:
		var instance = script.new()
		instance.call("run", controller)
	else:
		controller.log_error("console", "Failed to compile script!")
