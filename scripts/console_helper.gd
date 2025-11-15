class_name ConsoleHelper

static func register_internal_commands() -> void:
	_reg("/sleep", [ConsoleCommands.Argument.new("time", TYPE_FLOAT)], cmd_sleep, "Sleeps for a given time")
	_reg("/exec", [ConsoleCommands.Argument.new("file_name", TYPE_STRING)], cmd_exec, "Executes a .cfg file containing commands")
	_reg("/load_mod", [ConsoleCommands.Argument.new("file_name", TYPE_STRING)], cmd_load_mod, "Loads a .pck mod file")
	_reg("/load_script", [ConsoleCommands.Argument.new("file_name", TYPE_STRING)], cmd_load_script, "Loads a .gd script and executes its 'run' function")
	_reg("/clear", [], cmd_clear, "Clears console logs")
	_reg("/pause", [ConsoleCommands.Argument.new("pause", TYPE_BOOL)], cmd_pause, "Pauses and unpauses the game")
	_reg("/game-speed", [ConsoleCommands.Argument.new("time", TYPE_FLOAT)], cmd_game_speed, "Sets the current game speed")
	_reg("/version", [], cmd_version, "Prints the console version")
	_reg("/stats", [], cmd_stats, "Prints game performance related stats")
	_reg("/network", [], cmd_network, "Prints network related stats")
	_reg("/print", [ConsoleCommands.Argument.new("quote", TYPE_STRING)], cmd_print, "Prints words into the console")
	_reg("/help", [], cmd_help, "Lists the available commands")

# Helper to simplify registration
static func _reg(name: String, args: Array, func_ref: Callable, description : String = "") -> void:
	ConsoleCommands.register_command(name, args, func_ref, description)

static func cmd_sleep(controller: ConsoleController, args: Dictionary) -> void:
	await controller.get_tree().create_timer(args["time"]).timeout

static func cmd_exec(controller: ConsoleController, args: Dictionary) -> void:
	var code = _read_file(args["file_name"])
	if code == "":
		controller.log_error("console", "File not found or invalid!")
		return
	ConsoleCommands.run_command(controller, code)

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
	run_text_script(controller, script_code)

static func cmd_clear(controller: ConsoleController) -> void:
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

static func cmd_network(controller: ConsoleController) -> void:
	controller.log_info("console", "Machine network address: %s" % get_local_ip())

static func cmd_print(controller: ConsoleController, args: Dictionary) -> void:
	controller.log_info("console", args["quote"])

static func cmd_help(controller: ConsoleController) -> void:
	var all_cmds: Array[String] = ConsoleCommands.get_commands()
	if all_cmds.is_empty():
		controller.log_error("console", " - No commands registered -")
	else:
		controller.log_rainbow("console", "Available commands:")
		for cmd in all_cmds:
			var cmd_description: String = ConsoleCommands.get_command_by_id(cmd).description
			if cmd_description.is_empty():
				controller.log_info("console", "  [i]%s[/i]" % [cmd])
			else:
				controller.log_info("console", "  [i]%s[/i] - (%s)" % [cmd, cmd_description])

# Helper functions
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

static func run_text_script(controller: ConsoleController, code: String) -> void:
	var script = GDScript.new()
	script.source_code = code
	var error = script.reload()
	if error == OK:
		var instance = script.new()
		instance.call("run", controller)
	else:
		controller.log_error("console", "Failed to compile script!")
